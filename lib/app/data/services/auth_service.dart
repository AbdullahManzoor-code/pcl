import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'dart:async';
import '../models/user_model.dart';
import 'api_config.dart';
import 'local_profile_service.dart';
import 'network_error_handler.dart';
import '../../core/utils/app_logger.dart';

/// Real API Authentication Service
/// Handles login, registration, token refresh, and logout with Next.js backend

class AuthService extends GetxService {
  static String get apiBaseUrl => ApiConfig.baseUrl;
  static const int requestTimeoutSeconds = 10;
  static const String tokenStorageKey = 'auth_access_token';
  static const String tokenExpirationStorageKey = 'auth_token_expiration';
  static const String refreshTokenStorageKey = 'auth_refresh_token';

  final _localProfile = Get.find<LocalProfileService>();
  final _storage = GetStorage();
  String? _accessToken;
  String? _refreshToken;
  DateTime? _tokenExpiresAt;
  bool _isRefreshing = false;

  void _setRefreshToken(String? token) {
    _refreshToken = token;
    if (token != null) {
      _storage.write(refreshTokenStorageKey, token);
    } else {
      _storage.remove(refreshTokenStorageKey);
    }
  }

  /// Extract refresh token from Set-Cookie header when backend sends tokens
  /// as httpOnly cookies instead of JSON body fields.
  String? _extractRefreshTokenFromSetCookie(String? setCookieHeader) {
    if (setCookieHeader == null || setCookieHeader.isEmpty) return null;
    final match = RegExp(
      r'refresh_token=([^;,\s]+)',
    ).firstMatch(setCookieHeader);
    return match?.group(1);
  }

  /// Initialize service
  @override
  void onInit() {
    super.onInit();
    AppLogger.info('AuthService.onInit(): initialized');
  }

  /// Returns the last stored authenticated user, if available.
  User? getStoredUser() {
    final storedUserId = _storage.read('userId') as String?;
    final storedEmail = _storage.read('userEmail') as String?;
    final storedName = _storage.read('userName') as String?;
    final storedPhone = _storage.read('userPhone') as String?;
    final storedAltEmail = _storage.read('userAltEmail') as String?;
    final storedProfilePicUrl = _storage.read('profilePicUrl') as String?;
    if (storedUserId == null && storedEmail == null) {
      return null;
    }

    final user = User(
      id: storedUserId,
      email: storedEmail,
      name: storedName,
      phone: storedPhone,
      altEmail: storedAltEmail,
      profilePicUrl: storedProfilePicUrl,
    );

    return _localProfile.mergeWithRealUser(user);
  }

  /// Parse JWT token to extract expiration and other claims
  /// Returns decoded payload or null if invalid
  Map<String, dynamic>? _parseJWT(String token) {
    try {
      // Trim whitespace and surrounding quotes
      token = token.trim();
      if (token.isEmpty) return null;
      // JWT format: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) return null;
      String payload = parts[1];
      // Ensure proper padding for base64 decoding
      int mod = payload.length % 4;
      if (mod != 0) payload += '=' * (4 - mod);
      // First attempt URL-safe base64 decoding
      try {
        final decoded = utf8.decode(base64Url.decode(payload));
        return jsonDecode(decoded) as Map<String, dynamic>?;
      } catch (_) {
        // Fallback: replace URL-safe chars and use standard base64 decoder
        final sanitized = payload.replaceAll('-', '+').replaceAll('_', '/');
        final decoded = utf8.decode(base64.decode(sanitized));
        return jsonDecode(decoded) as Map<String, dynamic>?;
      }
    } catch (e, stackTrace) {
      AppLogger.warning(
        'AuthService._parseJWT(): failed to parse token',
        e,
        stackTrace,
      );
      return null;
    }
  }
  // Duplicate JWT parsing block removed

  /// Set token and calculate expiration time, also persist to storage
  void _setToken(String token) {
    _accessToken = token;

    // Persist token to GetStorage
    _storage.write(tokenStorageKey, token);

    // Parse JWT to get expiration
    final payload = _parseJWT(token);
    if (payload != null && payload.containsKey('exp')) {
      final expSeconds = payload['exp'] as int;
      _tokenExpiresAt = DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000);
    } else {
      // No expiration info; assume token valid for 5 minutes
      _tokenExpiresAt = DateTime.now().add(const Duration(minutes: 5));
      AppLogger.warning(
        'AuthService._setToken(): no exp claim found, defaulting expiration to 5 minutes',
      );
    }
    // Persist expiration time to storage
    _storage.write(
      tokenExpirationStorageKey,
      _tokenExpiresAt?.toIso8601String(),
    );
  }

  /// Check if token is truly expired (past expiration, not just within buffer)
  bool _isTokenTrulyExpired() {
    if (_accessToken == null || _tokenExpiresAt == null) {
      return true;
    }
    return _tokenExpiresAt!.isBefore(DateTime.now());
  }

  /// Check if token is expired or about to expire (within 5 minutes)
  bool _isTokenExpired() {
    if (_accessToken == null || _tokenExpiresAt == null) {
      return true;
    }

    final now = DateTime.now();
    // Consider expired if less than 5 minutes remaining
    final expiresIn = _tokenExpiresAt!.difference(now);
    return expiresIn.inMinutes < 5;
  }

  /// Refresh token if about to expire.
  /// Returns true if token is valid (either still good, or successfully refreshed).
  /// Returns false only if the token has TRULY expired and refresh failed.
  Future<bool> _ensureTokenValid() async {
    if (_isTokenExpired()) {
      AppLogger.warning(
        'AuthService._ensureTokenValid(): token expiring soon, refreshing',
      );
      final refreshed = await refreshToken();
      if (!refreshed) {
        // Refresh failed — only treat as fatal if token is truly expired
        if (_isTokenTrulyExpired()) {
          AppLogger.error(
            'AuthService._ensureTokenValid(): token truly expired and refresh failed',
          );
          return false;
        }
        // Token still has some time left — allow request to proceed
        AppLogger.warning(
          'AuthService._ensureTokenValid(): refresh failed but token still valid, proceeding',
        );
        return true;
      }
    }
    return true;
  }

  /// Login with email and password with retry logic
  Future<User> login(String email, String password) async {
    return NetworkErrorHandler.executeWithRetry(
      () => _performLogin(email, password),
      operationName: 'Login',
      policy: RetryPolicy.authRetry,
    );
  }

  /// Internal login implementation
  Future<User> _performLogin(String email, String password) async {
    try {
      AppLogger.info(
        'AuthService._performLogin(): POST /auth/login email=$email',
      );

      // Check connectivity first
      final canReach = await ConnectivityHelper.canReachServer(apiBaseUrl);
      if (!canReach) {
        throw NetworkException(
          type: NetworkErrorType.noInternet,
          message:
              'Cannot reach server. Please check your internet connection.',
        );
      }

      final response = await http
          .post(
            Uri.parse('$apiBaseUrl/api/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Login request timeout'),
          );

      AppLogger.debug(
        'AuthService._performLogin(): response status=${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _setToken(data['access_token']);
        final refreshTokenFromBody = data['refresh_token'] as String?;
        final refreshTokenFromCookie = _extractRefreshTokenFromSetCookie(
          response.headers['set-cookie'],
        );
        _setRefreshToken(refreshTokenFromBody ?? refreshTokenFromCookie);

        AppLogger.info(
          'AuthService._performLogin(): success, responseKeys=${data.keys.join(', ')}',
        );

        // Convert API response and merge with mock data
        final realUser = User.fromLoginResponse(data);
        final user = _localProfile.mergeWithRealUser(realUser);
        // Persist user info to storage
        _storage.write('userId', user.id);
        _storage.write('userEmail', user.email);
        if (user.name != null) _storage.write('userName', user.name);
        if (user.phone != null) _storage.write('userPhone', user.phone);
        if (user.altEmail != null)
          _storage.write('userAltEmail', user.altEmail);
        if (user.profilePicUrl != null)
          _storage.write('profilePicUrl', user.profilePicUrl);
        AppLogger.info(
          'AuthService._performLogin(): parsed user id=${user.id}, email=${user.email}',
        );
        return user;
      } else if (response.statusCode == 401) {
        throw NetworkException(
          type: NetworkErrorType.unauthorized,
          message: 'Invalid credentials',
          statusCode: 401,
        );
      } else {
        try {
          final error = jsonDecode(response.body);
          throw NetworkException(
            type: NetworkErrorHandler.detectErrorType(
              null,
              response.statusCode,
            ),
            message: error['detail'] ?? 'Login failed',
            statusCode: response.statusCode,
            details: response.body,
          );
        } catch (e) {
          if (e is NetworkException) rethrow;
          throw NetworkException(
            type: NetworkErrorHandler.detectErrorType(
              null,
              response.statusCode,
            ),
            message: 'Login failed with status ${response.statusCode}',
            statusCode: response.statusCode,
          );
        }
      }
    } on NetworkException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'AuthService._performLogin(): login failed',
        e,
        stackTrace,
      );
      throw NetworkErrorHandler.createException(e, 'Login failed');
    }
  }

  /// Register new user with retry logic
  Future<User> register(
    String email,
    String password, {
    String? languageId,
    String? experienceLevel,
  }) async {
    return NetworkErrorHandler.executeWithRetry(
      () => _performRegister(email, password, languageId, experienceLevel),
      operationName: 'Register',
      policy: RetryPolicy.authRetry,
    );
  }

  /// Internal register implementation
  Future<User> _performRegister(
    String email,
    String password,
    String? languageId,
    String? experienceLevel,
  ) async {
    try {
      AppLogger.info(
        'AuthService._performRegister(): POST /api/auth/register email=$email, languageId=$languageId, experienceLevel=$experienceLevel',
      );

      // Check connectivity first
      final canReach = await ConnectivityHelper.canReachServer(apiBaseUrl);
      if (!canReach) {
        throw NetworkException(
          type: NetworkErrorType.noInternet,
          message:
              'Cannot reach server. Please check your internet connection.',
        );
      }

      final response = await http
          .post(
            Uri.parse('$apiBaseUrl/api/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
              if (languageId != null) 'language_id': languageId,
              if (experienceLevel != null) 'experience_level': experienceLevel,
            }),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw TimeoutException('Registration request timeout'),
          );

      AppLogger.debug(
        'AuthService._performRegister(): response status=${response.statusCode}',
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _setToken(data['access_token']);
        final refreshTokenFromBody = data['refresh_token'] as String?;
        final refreshTokenFromCookie = _extractRefreshTokenFromSetCookie(
          response.headers['set-cookie'],
        );
        _setRefreshToken(refreshTokenFromBody ?? refreshTokenFromCookie);

        AppLogger.info(
          'AuthService._performRegister(): success, responseKeys=${data.keys.join(', ')}',
        );

        // Convert API response and merge with mock data
        final realUser = User.fromJson(data);
        final user = _localProfile.mergeWithRealUser(realUser);
        
        // Persist user info to storage
        _storage.write('userId', user.id);
        _storage.write('userEmail', user.email);
        if (user.name != null) _storage.write('userName', user.name);
        if (user.phone != null) _storage.write('userPhone', user.phone);
        if (user.altEmail != null)
          _storage.write('userAltEmail', user.altEmail);
        if (user.profilePicUrl != null)
          _storage.write('profilePicUrl', user.profilePicUrl);
        AppLogger.info(
          'AuthService._performRegister(): parsed user id=${user.id}, email=${user.email}',
        );
        return user;
      } else if (response.statusCode == 409) {
        throw NetworkException(
          type: NetworkErrorType.conflict,
          message: 'Email already registered',
          statusCode: 409,
        );
      } else if (response.statusCode == 400) {
        try {
          final error = jsonDecode(response.body);
          throw NetworkException(
            type: NetworkErrorType.badRequest,
            message: error['detail'] ?? 'Invalid request',
            statusCode: 400,
            details: response.body,
          );
        } catch (e) {
          if (e is NetworkException) rethrow;
          throw NetworkException(
            type: NetworkErrorType.badRequest,
            message: 'Invalid request',
            statusCode: 400,
          );
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          throw NetworkException(
            type: NetworkErrorHandler.detectErrorType(
              null,
              response.statusCode,
            ),
            message: error['detail'] ?? 'Registration failed',
            statusCode: response.statusCode,
            details: response.body,
          );
        } catch (e) {
          if (e is NetworkException) rethrow;
          throw NetworkException(
            type: NetworkErrorHandler.detectErrorType(
              null,
              response.statusCode,
            ),
            message: 'Registration failed with status ${response.statusCode}',
            statusCode: response.statusCode,
          );
        }
      }
    } on NetworkException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'AuthService._performRegister(): registration failed',
        e,
        stackTrace,
      );
      throw NetworkErrorHandler.createException(e, 'Registration failed');
    }
  }

  /// Get current user profile with auto-retry
  Future<User> getMe() async {
    if (_accessToken == null) {
      final storedToken = _storage.read(tokenStorageKey) as String?;
      if (storedToken == null) {
        throw NetworkException(
          type: NetworkErrorType.unauthorized,
          message: 'No access token available',
        );
      }
      _setToken(storedToken);
    }

    // Also restore refresh token from storage if not already loaded
    _refreshToken ??= _storage.read(refreshTokenStorageKey) as String?;

    // Also restore expiration time from storage if not in memory
    if (_tokenExpiresAt == null) {
      final storedExpiration =
          _storage.read(tokenExpirationStorageKey) as String?;
      if (storedExpiration != null) {
        _tokenExpiresAt = DateTime.tryParse(storedExpiration);
      }
    }

    return NetworkErrorHandler.executeWithRetry(
      () => _performGetMe(),
      operationName: 'GetMe',
      policy: RetryPolicy.defaultRetry,
    );
  }

  /// Internal getMe implementation
  Future<User> _performGetMe() async {
    // Ensure token is still valid
    final tokenValid = await _ensureTokenValid();
    if (!tokenValid) {
      throw NetworkException(
        type: NetworkErrorType.unauthorized,
        message: 'Session expired. Please log in again.',
      );
    }

    try {
      AppLogger.info('AuthService._performGetMe(): GET /api/auth/me');

      final response = await http
          .get(
            Uri.parse('$apiBaseUrl/api/auth/me'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_accessToken',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final realUser = User.fromJson(data);
        final user = _localProfile.mergeWithRealUser(realUser);
        // Persist user info
        _storage.write('userId', user.id);
        _storage.write('userEmail', user.email);
        if (user.name != null) _storage.write('userName', user.name);
        if (user.phone != null) _storage.write('userPhone', user.phone);
        if (user.altEmail != null)
          _storage.write('userAltEmail', user.altEmail);
        if (user.profilePicUrl != null)
          _storage.write('profilePicUrl', user.profilePicUrl);
        AppLogger.info(
          'AuthService._performGetMe(): success, userId=${user.id}',
        );
        return user;
      } else if (response.statusCode == 401) {
        final refreshed = await refreshToken();
        if (refreshed) {
          return _performGetMe(); // Retry after successful refresh
        }
        throw NetworkException(
          type: NetworkErrorType.unauthorized,
          message: 'Session expired',
          statusCode: 401,
        );
      } else {
        throw NetworkException(
          type: NetworkErrorHandler.detectErrorType(null, response.statusCode),
          message: 'Failed to fetch user profile',
          statusCode: response.statusCode,
          details: response.body,
        );
      }
    } on TimeoutException {
      throw NetworkException(
        type: NetworkErrorType.timeout,
        message: 'Request to get user profile timed out',
      );
    } on NetworkException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('AuthService._performGetMe(): failed', e, stackTrace);
      throw NetworkErrorHandler.createException(
        e,
        'An unexpected error occurred while fetching your profile',
      );
    }
  }

  /// Refresh the access token using the stored refresh token
  Future<bool> refreshToken() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;

    // Load from storage if not in memory
    _refreshToken ??= _storage.read(refreshTokenStorageKey);

    if (_refreshToken == null) {
      AppLogger.warning(
        'AuthService.refreshToken(): no refresh token available',
      );
      _isRefreshing = false;
      await logout(); // Logout if refresh token is missing
      return false;
    }

    try {
      AppLogger.info('AuthService.refreshToken(): POST /api/auth/refresh');
      final response = await http
          .post(
            Uri.parse('$apiBaseUrl/api/auth/refresh'),
            headers: {
              'Content-Type': 'application/json',
              'Cookie': 'refresh_token=$_refreshToken',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _setToken(data['access_token']);
        AppLogger.info('AuthService.refreshToken(): success');
        _isRefreshing = false;
        return true;
      } else {
        AppLogger.error(
          'AuthService.refreshToken(): failed status=${response.statusCode}, body=${response.body}',
        );
        await logout(); // Logout on refresh failure
        _isRefreshing = false;
        return false;
      }
    } catch (e, stackTrace) {
      AppLogger.error('AuthService.refreshToken(): failed', e, stackTrace);
      await logout(); // Logout on error
      _isRefreshing = false;
      return false;
    }
  }

  /// Logout user by clearing local tokens and storage
  Future<void> logout() async {
    AppLogger.info('AuthService.logout()');
    _accessToken = null;
    _refreshToken = null;
    _tokenExpiresAt = null;

    // Clear from GetStorage
    await _storage.remove(tokenStorageKey);
    await _storage.remove(tokenExpirationStorageKey);
    await _storage.remove(refreshTokenStorageKey);
    await _storage.remove('userId');
    await _storage.remove('userEmail');
    await _storage.remove('userName');
    await _storage.remove('userPhone');
    await _storage.remove('userAltEmail');
    await _storage.remove('profilePicUrl');
  }

  /// CHANGE PASSWORD
  Future<void> changePassword(String oldPassword, String newPassword) async {
    if (_accessToken == null) {
      throw NetworkException(
        type: NetworkErrorType.unauthorized,
        message: 'Not logged in',
      );
    }
    await _ensureTokenValid();

    try {
      AppLogger.info(
        'AuthService.changePassword(): POST /api/auth/change-password',
      );
      final response = await http
          .post(
            Uri.parse('$apiBaseUrl/api/auth/change-password'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_accessToken',
            },
            body: jsonEncode({
              'current_password': oldPassword,
              'new_password': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        String message = 'Failed to change password.';
        if (response.body.isNotEmpty) {
          try {
            final error = jsonDecode(response.body);
            message = error['detail'] ?? message;
          } catch (_) {}
        }
        throw NetworkException(
          type: NetworkErrorHandler.detectErrorType(null, response.statusCode),
          message: message,
          statusCode: response.statusCode,
        );
      }
      AppLogger.info('AuthService.changePassword(): success');
    } on TimeoutException {
      throw NetworkException(
        type: NetworkErrorType.timeout,
        message: 'Request timed out',
      );
    } on NetworkException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('AuthService.changePassword(): failed', e, stackTrace);
      throw NetworkErrorHandler.createException(
        e,
        'An unexpected error occurred.',
      );
    }
  }

  /// UPDATE USER PROFILE
  Future<User> updateProfile(Map<String, dynamic> data) async {
    if (_accessToken == null) {
      throw NetworkException(
        type: NetworkErrorType.unauthorized,
        message: 'Not logged in',
      );
    }
    await _ensureTokenValid();

    try {
      AppLogger.info('AuthService.updateProfile(): PUT /api/auth/profile');
      final response = await http
          .put(
            Uri.parse('$apiBaseUrl/api/auth/profile'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_accessToken',
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final realUser = User.fromJson(responseData);
        final user = _localProfile.mergeWithRealUser(realUser);
        // Update local storage
        _storage.write('userName', user.name);
        _storage.write('userEmail', user.email);
        _storage.write('userPhone', user.phone);
        if (user.altEmail != null)
          _storage.write('userAltEmail', user.altEmail);
        if (user.profilePicUrl != null)
          _storage.write('profilePicUrl', user.profilePicUrl);
        AppLogger.info('AuthService.updateProfile(): success');
        return user;
      } else {
        String message = 'Failed to update profile.';
        if (response.body.isNotEmpty) {
          try {
            final error = jsonDecode(response.body);
            message = error['detail'] ?? message;
          } catch (_) {}
        }
        throw NetworkException(
          type: NetworkErrorHandler.detectErrorType(null, response.statusCode),
          message: message,
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      throw NetworkException(
        type: NetworkErrorType.timeout,
        message: 'Request timed out',
      );
    } on NetworkException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('AuthService.updateProfile(): failed', e, stackTrace);
      throw NetworkErrorHandler.createException(
        e,
        'An unexpected error occurred.',
      );
    }
  }

  String? getAccessToken() => _accessToken;

  /// Check if user is authenticated (token exists and is not expired)
  bool isAuthenticated() {
    return _accessToken != null && !_isTokenExpired();
  }

  /// Restore session from persistent storage. Returns true if successful.
  Future<bool> restoreSession() async {
    AppLogger.info('AuthService.restoreSession(): attempting to restore');
    final storedToken = _storage.read(tokenStorageKey) as String?;
    final storedRefreshToken = _storage.read(refreshTokenStorageKey) as String?;

    if (storedToken == null) {
      AppLogger.warning('AuthService.restoreSession(): no token in storage');
      return false;
    }

    _setToken(storedToken);
    _setRefreshToken(storedRefreshToken);

    if (_isTokenExpired()) {
      AppLogger.warning(
        'AuthService.restoreSession(): token expired, attempting refresh',
      );
      return await refreshToken();
    }

    AppLogger.info('AuthService.restoreSession(): success');
    return true;
  }

  /// Check if a session token exists in storage (doesn't validate it)
  bool isSessionValid() {
    return _storage.read(tokenStorageKey) != null;
  }
}

/// Helper to check network connectivity before making API calls
class ConnectivityHelper {
  static Future<bool> canReachServer(String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await http.head(uri).timeout(const Duration(seconds: 3));
      // Assume reachability if we get any response, even an error code
      AppLogger.debug(
        'Connectivity check to $url OK (status ${response.statusCode})',
      );
      return true;
    } catch (e) {
      AppLogger.warning('Connectivity check to $url FAILED', e);
      return false;
    }
  }
}

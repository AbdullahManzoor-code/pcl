import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'dart:async';
import '../models/user_model.dart';
import 'api_config.dart';
import 'api_adapter_service.dart';
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

  final _adapter = Get.find<ApiAdapterService>();
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
    final mergedUser = _adapter.getMergedUser();
    if (mergedUser != null) {
      return mergedUser;
    }

    final storedUserId = _storage.read('userId') as String?;
    final storedEmail = _storage.read('userEmail') as String?;
    if (storedUserId == null && storedEmail == null) {
      return null;
    }

    return User(id: storedUserId, email: storedEmail);
  }

  /// Parse JWT token to extract expiration and other claims
  /// Returns decoded payload or null if invalid
  Map<String, dynamic>? _parseJWT(String token) {
    try {
      // JWT format: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decode payload (add padding if needed)
      String payload = parts[1];
      // Add padding
      payload += List<String>.filled(4 - payload.length % 4, '=').join('');
      final decoded = utf8.decode(base64Url.decode(payload));
      return jsonDecode(decoded);
    } catch (e, stackTrace) {
      AppLogger.warning(
        'AuthService._parseJWT(): failed to parse token',
        e,
        stackTrace,
      );
      return null;
    }
  }

  /// Set token and calculate expiration time, also persist to storage
  void _setToken(String token) {
    _accessToken = token;

    // Persist token to GetStorage
    _storage.write(tokenStorageKey, token);

    // Parse JWT to get expiration
    final payload = _parseJWT(token);
    if (payload != null && payload.containsKey('exp')) {
      // exp is in seconds since epoch
      final expSeconds = payload['exp'] as int;
      _tokenExpiresAt = DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000);

      // Persist expiration time to storage
      _storage.write(
        tokenExpirationStorageKey,
        _tokenExpiresAt?.toIso8601String(),
      );

      final duration = _tokenExpiresAt!.difference(DateTime.now());
      AppLogger.info(
        'AuthService._setToken(): expiresAt=${_tokenExpiresAt?.toIso8601String()}, expiresIn=${duration.inMinutes} minutes',
      );
    }
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

  /// Refresh token if about to expire
  Future<bool> _ensureTokenValid() async {
    if (_isTokenExpired()) {
      AppLogger.warning(
        'AuthService._ensureTokenValid(): token expiring soon, refreshing',
      );
      return await refreshToken();
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
        final user = _adapter.convertLoginResponse(data);
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
        final user = User.fromJson(data);
        _adapter.saveMockUserData(user);
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
      throw NetworkException(
        type: NetworkErrorType.unauthorized,
        message: 'No access token available',
      );
    }

    return NetworkErrorHandler.executeWithRetry(
      () => _performGetMe(),
      operationName: 'GetMe',
      policy: RetryPolicy.defaultRetry,
    );
  }

  /// Internal getMe implementation
  Future<User> _performGetMe() async {
    const cacheKey = 'cache_user_profile';

    // Ensure token is still valid
    final tokenValid = await _ensureTokenValid();
    if (!tokenValid) {
      // Offline fallback if token invalid but we have cache
      final cachedData = _storage.read(cacheKey);
      if (cachedData != null) {
        AppLogger.warning(
          'AuthService._performGetMe(): loading cached profile because token is invalid',
        );
        return _adapter.convertProfileResponse(jsonDecode(cachedData));
      }
      throw NetworkException(
        type: NetworkErrorType.unauthorized,
        message: 'Session expired',
      );
    }

    try {
      AppLogger.info(
        'AuthService._performGetMe(): fetching current user profile',
      );

      // Check connectivity
      final canReach = await ConnectivityHelper.canReachServer(apiBaseUrl);
      if (!canReach) {
        final cachedData = _storage.read(cacheKey);
        if (cachedData != null) {
          AppLogger.warning(
            'AuthService._performGetMe(): loading cached profile',
          );
          return _adapter.convertProfileResponse(jsonDecode(cachedData));
        }
        throw NetworkException(
          type: NetworkErrorType.noInternet,
          message: 'Cannot reach server',
        );
      }

      final response = await http
          .get(
            Uri.parse('$apiBaseUrl/api/auth/me'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_accessToken',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('GetMe request timeout'),
          );

      AppLogger.debug(
        'AuthService._performGetMe(): response status=${response.statusCode}',
      );

      if (response.statusCode == 200) {
        // Cache successful response
        _storage.write(cacheKey, response.body);

        final data = jsonDecode(response.body);
        AppLogger.info(
          'AuthService._performGetMe(): success, responseKeys=${data.keys.join(', ')}',
        );
        // Convert API response and merge with mock data
        final user = _adapter.convertProfileResponse(data);
        return user;
      } else if (response.statusCode == 401) {
        AppLogger.warning(
          'AuthService._performGetMe(): token expired, refreshing',
        );
        // Try to refresh token
        final refreshed = await refreshToken();
        if (refreshed) {
          AppLogger.info(
            'AuthService._performGetMe(): token refreshed, retrying',
          );
          // Retry getMe with new token
          return _performGetMe();
        }
        throw NetworkException(
          type: NetworkErrorType.unauthorized,
          message: 'Session expired',
          statusCode: 401,
        );
      } else {
        throw NetworkException(
          type: NetworkErrorHandler.detectErrorType(null, response.statusCode),
          message: 'Failed to get profile',
          statusCode: response.statusCode,
        );
      }
    } on NetworkException {
      rethrow;
    } catch (e) {
      AppLogger.error(
        'AuthService._performGetMe(): failed to fetch profile',
        e,
      );

      // Fallback to cache for any unexpected errors
      final cachedData = _storage.read(cacheKey);
      if (cachedData != null) {
        AppLogger.warning(
          'AuthService._performGetMe(): falling back to cached profile after error',
        );
        return _adapter.convertProfileResponse(jsonDecode(cachedData));
      }

      throw NetworkErrorHandler.createException(e, 'Failed to fetch profile');
    }
  }

  /// Refresh access token with retry logic
  Future<bool> refreshToken() async {
    // Prevent multiple simultaneous refresh attempts
    if (_isRefreshing) {
      AppLogger.warning(
        'AuthService.refreshToken(): already refreshing, waiting',
      );
      // Wait a bit and check if token was refreshed
      await Future.delayed(const Duration(milliseconds: 500));
      return _accessToken != null;
    }

    _isRefreshing = true;
    try {
      AppLogger.info('AuthService.refreshToken(): sending refresh request');

      // Check connectivity
      final canReach = await ConnectivityHelper.canReachServer(apiBaseUrl);
      if (!canReach) {
        AppLogger.warning('AuthService.refreshToken(): no internet connection');
        return false;
      }

      final refToken = _refreshToken ?? _storage.read(refreshTokenStorageKey);
      if (refToken == null) {
        AppLogger.warning(
          'AuthService.refreshToken(): no refresh token stored',
        );
        return false;
      }

      final response = await http
          .post(
            Uri.parse('$apiBaseUrl/api/auth/refresh'),
            headers: {
              'Content-Type': 'application/json',
              'Cookie': 'refresh_token=$refToken',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              AppLogger.warning('AuthService.refreshToken(): timeout');
              return http.Response('{"detail": "Timeout"}', 504);
            },
          );

      AppLogger.debug(
        'AuthService.refreshToken(): response status=${response.statusCode}',
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
          'AuthService.refreshToken(): token refreshed successfully',
        );
        return true;
      } else if (response.statusCode == 401) {
        AppLogger.error('AuthService.refreshToken(): invalid refresh token');
        _accessToken = null;
        _refreshToken = null;
        _tokenExpiresAt = null;
        return false;
      } else {
        AppLogger.warning(
          'AuthService.refreshToken(): unexpected status=${response.statusCode}',
        );
        // For server errors, could retry, but usually better to fail fast
        return false;
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'AuthService.refreshToken(): refresh failed',
        e,
        stackTrace,
      );
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      AppLogger.info('AuthService.logout(): logging out user');

      if (_accessToken != null) {
        try {
          await http
              .post(
                Uri.parse('$apiBaseUrl/api/auth/logout'),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $_accessToken',
                },
              )
              .timeout(const Duration(seconds: 5));

          AppLogger.info('AuthService.logout(): API call successful');
        } on TimeoutException {
          AppLogger.warning(
            'AuthService.logout(): API call timed out but clearing local data',
          );
        } catch (e) {
          AppLogger.warning(
            'AuthService.logout(): API call failed but clearing local data',
            e,
          );
        }
      }
    } catch (e, stackTrace) {
      AppLogger.warning(
        'AuthService.logout(): unexpected error',
        e,
        stackTrace,
      );
    } finally {
      _accessToken = null;
      _refreshToken = null;
      _tokenExpiresAt = null;
      _isRefreshing = false;

      // Clear from storage
      _storage.remove(tokenStorageKey);
      _storage.remove(tokenExpirationStorageKey);
      _storage.remove(refreshTokenStorageKey);

      _adapter.clearUserData();
      AppLogger.info(
        'AuthService.logout(): local data and session storage cleared',
      );
    }
  }

  /// Change user password
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (_accessToken == null) {
      throw NetworkException(
        type: NetworkErrorType.unauthorized,
        message: 'No access token available',
      );
    }

    try {
      final response = await http
          .post(
            Uri.parse('$apiBaseUrl/api/auth/change-password'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_accessToken',
            },
            body: jsonEncode({
              'current_password': currentPassword,
              'new_password': newPassword,
            }),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw TimeoutException('Change password request timeout'),
          );

      if (response.statusCode != 200) {
        try {
          final error = jsonDecode(response.body);
          throw NetworkException(
            type: NetworkErrorHandler.detectErrorType(
              null,
              response.statusCode,
            ),
            message: error['detail'] ?? 'Failed to change password',
            statusCode: response.statusCode,
          );
        } catch (e) {
          if (e is NetworkException) rethrow;
          throw NetworkException(
            type: NetworkErrorHandler.detectErrorType(
              null,
              response.statusCode,
            ),
            message: 'Failed to change password',
            statusCode: response.statusCode,
          );
        }
      }
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkErrorHandler.createException(e, 'Failed to change password');
    }
  }

  /// Update user profile (language and experience level)
  Future<void> updateProfile(String languageId, String experienceLevel) async {
    if (_accessToken == null) {
      throw NetworkException(
        type: NetworkErrorType.unauthorized,
        message: 'No access token available',
      );
    }

    try {
      final response = await http
          .put(
            Uri.parse('$apiBaseUrl/api/auth/profile'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_accessToken',
            },
            body: jsonEncode({
              'language_id': languageId,
              'experience_level': experienceLevel,
            }),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw TimeoutException('Update profile request timeout'),
          );

      if (response.statusCode != 200) {
        try {
          final error = jsonDecode(response.body);
          throw NetworkException(
            type: NetworkErrorHandler.detectErrorType(
              null,
              response.statusCode,
            ),
            message: error['detail'] ?? 'Failed to update profile',
            statusCode: response.statusCode,
          );
        } catch (e) {
          if (e is NetworkException) rethrow;
          throw NetworkException(
            type: NetworkErrorHandler.detectErrorType(
              null,
              response.statusCode,
            ),
            message: 'Failed to update profile',
            statusCode: response.statusCode,
          );
        }
      }
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkErrorHandler.createException(e, 'Failed to update profile');
    }
  }

  /// Get stored access token
  String? getAccessToken() => _accessToken;

  /// Set access token (useful for restoring session)
  void setAccessToken(String token) {
    _setToken(token);
  }

  /// Check if user is authenticated
  bool isAuthenticated() => _accessToken != null && !_isTokenExpired();

  /// Get token expiration time
  DateTime? getTokenExpiresAt() => _tokenExpiresAt;

  /// Get remaining time until token expiration
  Duration? getTokenExpiresIn() {
    if (_tokenExpiresAt == null) return null;
    return _tokenExpiresAt!.difference(DateTime.now());
  }

  /// Check if token is expired
  bool isTokenExpired() => _isTokenExpired();

  /// Restore session from persistent storage
  /// Returns true if session was successfully restored
  Future<bool> restoreSession() async {
    try {
      AppLogger.info(
        'AuthService.restoreSession(): attempting to restore session',
      );

      final storedToken = _storage.read(tokenStorageKey);
      final storedExpiration = _storage.read(tokenExpirationStorageKey);
      final storedRefreshToken = _storage.read(refreshTokenStorageKey);

      if (storedToken == null) {
        AppLogger.warning(
          'AuthService.restoreSession(): no stored token found',
        );
        return false;
      }

      AppLogger.info('AuthService.restoreSession(): stored token found');

      // Restore token and expiration
      _accessToken = storedToken;
      _refreshToken = storedRefreshToken;
      if (storedExpiration != null) {
        _tokenExpiresAt = DateTime.parse(storedExpiration);
      }

      // Check if token is still valid
      if (_isTokenExpired()) {
        AppLogger.warning(
          'AuthService.restoreSession(): stored token expired, refreshing',
        );

        // Try to refresh the token
        final refreshed = await refreshToken();
        if (!refreshed) {
          AppLogger.error(
            'AuthService.restoreSession(): token refresh failed, session expired',
          );
          _accessToken = null;
          _refreshToken = null;
          _tokenExpiresAt = null;
          _storage.remove(tokenStorageKey);
          _storage.remove(tokenExpirationStorageKey);
          _storage.remove(refreshTokenStorageKey);
          return false;
        }

        AppLogger.info(
          'AuthService.restoreSession(): token refreshed successfully',
        );
      }

      AppLogger.info(
        'AuthService.restoreSession(): session restored, expiresIn=${getTokenExpiresIn()?.inMinutes} minutes',
      );
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        'AuthService.restoreSession(): restore failed',
        e,
        stackTrace,
      );
      _accessToken = null;
      _tokenExpiresAt = null;
      _storage.remove(tokenStorageKey);
      _storage.remove(tokenExpirationStorageKey);
      return false;
    }
  }

  /// Check if there's a valid session in storage
  bool isSessionValid() {
    final storedToken = _storage.read(tokenStorageKey);
    return storedToken != null;
  }

  /// Verify session is still active on the backend
  /// This can be used as an optional extra check during restoration
  Future<bool> verifySession() async {
    if (_accessToken == null) {
      return false;
    }

    try {
      AppLogger.info('AuthService.verifySession(): checking backend session');
      final user = await getMe();
      AppLogger.info(
        'AuthService.verifySession(): session valid, user=${user.email}',
      );
      return true;
    } catch (e) {
      AppLogger.warning(
        'AuthService.verifySession(): session verification failed',
        e,
      );
      return false;
    }
  }
}

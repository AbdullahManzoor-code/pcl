import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/utils/app_logger.dart';

/// Error types for network operations
enum NetworkErrorType {
  /// No internet connection available
  noInternet,

  /// Request timed out
  timeout,

  /// Server error (5xx)
  serverError,

  /// Client error (4xx) - invalid request
  clientError,

  /// Invalid credentials (401)
  unauthorized,

  /// Resource not found (404)
  notFound,

  /// Email already exists (409)
  conflict,

  /// Bad request (400)
  badRequest,

  /// Forbidden (403)
  forbidden,

  /// SSL/TLS certificate error
  certificateError,

  /// Unknown/other error
  unknown,
}

/// Custom exception for network errors with detailed information
class NetworkException implements Exception {
  final NetworkErrorType type;
  final String message;
  final String? details;
  final dynamic originalError;
  final int? statusCode;

  NetworkException({
    required this.type,
    required this.message,
    this.details,
    this.originalError,
    this.statusCode,
  });

  @override
  String toString() => message;

  /// Get user-friendly error message
  String getUserMessage() {
    switch (type) {
      case NetworkErrorType.noInternet:
        return 'No internet connection. Please check your network and try again.';
      case NetworkErrorType.timeout:
        return 'Request timed out. Please check your connection and try again.';
      case NetworkErrorType.serverError:
        return 'Server error. Please try again later.';
      case NetworkErrorType.clientError:
        return 'Invalid request. Please check your input and try again.';
      case NetworkErrorType.unauthorized:
        return 'Invalid credentials. Please check your email and password.';
      case NetworkErrorType.notFound:
        return 'Resource not found. Please try again.';
      case NetworkErrorType.conflict:
        return 'Email already registered. Please log in or use a different email.';
      case NetworkErrorType.badRequest:
        return 'Invalid request. Please check your input.';
      case NetworkErrorType.forbidden:
        return 'Access denied. You do not have permission.';
      case NetworkErrorType.certificateError:
        return 'Security error. Please check your internet connection.';
      case NetworkErrorType.unknown:
        return 'An error occurred. Please try again.';
    }
  }
}

/// Retry policy for failed requests
class RetryPolicy {
  /// Maximum number of retry attempts
  final int maxRetries;

  /// Initial delay between retries in milliseconds
  final int initialDelayMs;

  /// Maximum delay between retries in milliseconds
  final int maxDelayMs;

  /// Backoff multiplier (exponential backoff)
  final double backoffMultiplier;

  /// Only retry on these error types
  final List<NetworkErrorType> retryableErrors;

  const RetryPolicy({
    this.maxRetries = 3,
    this.initialDelayMs = 500,
    this.maxDelayMs = 10000,
    this.backoffMultiplier = 2.0,
    this.retryableErrors = const [
      NetworkErrorType.timeout,
      NetworkErrorType.serverError,
      NetworkErrorType.noInternet,
    ],
  });

  /// Default policy for auth operations
  static const RetryPolicy authRetry = RetryPolicy(
    maxRetries: 2,
    initialDelayMs: 500,
    maxDelayMs: 5000,
  );

  /// Default policy for general operations
  static const RetryPolicy defaultRetry = RetryPolicy(
    maxRetries: 3,
    initialDelayMs: 500,
    maxDelayMs: 10000,
  );

  /// Policy with no retries
  static const RetryPolicy noRetry = RetryPolicy(maxRetries: 0);

  /// Calculate delay for given attempt number
  int getDelayForAttempt(int attempt) {
    if (attempt <= 0) return 0;

    final delay = (initialDelayMs * (backoffMultiplier * (attempt - 1)))
        .toInt();
    return delay.clamp(0, maxDelayMs);
  }

  /// Check if error should be retried
  bool shouldRetry(NetworkErrorType errorType) {
    return retryableErrors.contains(errorType);
  }
}

/// Network error handler with retry logic
class NetworkErrorHandler {
  static const String tag = '🌐 NETWORK';

  /// Detect error type from exception
  static NetworkErrorType detectErrorType(dynamic error, int? statusCode) {
    if (error is SocketException) {
      if (error.message.contains('Connection refused')) {
        return NetworkErrorType.noInternet;
      }
      return NetworkErrorType.noInternet;
    }

    if (error is TimeoutException ||
        error.toString().contains('timeout') ||
        error.toString().contains('SocketException')) {
      return NetworkErrorType.timeout;
    }

    if (error.toString().contains('certificate')) {
      return NetworkErrorType.certificateError;
    }

    // Handle HTTP status codes
    if (statusCode != null) {
      if (statusCode == 401) return NetworkErrorType.unauthorized;
      if (statusCode == 403) return NetworkErrorType.forbidden;
      if (statusCode == 404) return NetworkErrorType.notFound;
      if (statusCode == 409) return NetworkErrorType.conflict;
      if (statusCode == 400) return NetworkErrorType.badRequest;
      if (statusCode >= 500) return NetworkErrorType.serverError;
      if (statusCode >= 400) return NetworkErrorType.clientError;
    }

    return NetworkErrorType.unknown;
  }

  /// Parse error message from response body
  static String parseErrorMessage(String responseBody) {
    try {
      final data = Uri.decodeFull(responseBody);
      // Try to extract 'detail' field from JSON
      if (data.contains('detail')) {
        final startIdx = data.indexOf('"detail"') + 10;
        final endIdx = data.indexOf('"', startIdx);
        if (endIdx > startIdx) {
          return data.substring(startIdx, endIdx);
        }
      }
      return data.length > 100 ? data.substring(0, 100) : data;
    } catch (e) {
      return 'Unknown error occurred';
    }
  }

  /// Log network error with details
  static void logError(
    String operation,
    NetworkException error, {
    bool verbose = kDebugMode,
  }) {
    if (!verbose) return;

    AppLogger.error(
      '$tag ERROR in $operation: type=${error.type.toString().split('.').last}, message=${error.message}, statusCode=${error.statusCode}, details=${error.details}, original=${error.originalError}',
      error,
    );
  }

  /// Execute operation with retry logic
  static Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    String operationName = 'Operation',
    RetryPolicy policy = RetryPolicy.defaultRetry,
  }) async {
    int attempt = 0;
    NetworkException? lastError;

    while (attempt <= policy.maxRetries) {
      try {
        if (kDebugMode) {
          if (attempt == 0) {
            AppLogger.info(
              '$tag EXECUTE: $operationName (attempt ${attempt + 1}/${policy.maxRetries + 1})',
            );
          } else {
            AppLogger.warning(
              '$tag RETRY: $operationName (attempt ${attempt + 1}/${policy.maxRetries + 1})',
            );
          }
        }

        return await operation();
      } on NetworkException catch (e) {
        lastError = e;
        logError(operationName, e);

        // Check if we should retry
        if (attempt < policy.maxRetries && policy.shouldRetry(e.type)) {
          final delay = policy.getDelayForAttempt(attempt + 1);
          if (kDebugMode) {
            AppLogger.warning('$tag WAIT: ${delay}ms before retry...');
          }
          await Future.delayed(Duration(milliseconds: delay));
          attempt++;
        } else {
          // No more retries or error not retryable
          rethrow;
        }
      } catch (e, stackTrace) {
        if (kDebugMode) {
          AppLogger.error('$tag UNEXPECTED ERROR: $e', e, stackTrace);
        }
        // Wrap unknown errors
        final errorType = detectErrorType(e, null);
        throw NetworkException(
          type: errorType,
          message: 'Unexpected error: $e',
          originalError: e,
        );
      }
    }

    // All retries exhausted
    if (lastError != null) {
      throw lastError;
    }

    throw NetworkException(
      type: NetworkErrorType.unknown,
      message: 'Operation failed after ${policy.maxRetries + 1} attempts',
    );
  }

  /// Create network exception from error details
  static NetworkException createException(
    dynamic error,
    String defaultMessage, {
    int? statusCode,
    String? responseBody,
  }) {
    final errorType = detectErrorType(error, statusCode);
    final message = responseBody != null
        ? parseErrorMessage(responseBody)
        : defaultMessage;

    return NetworkException(
      type: errorType,
      message: message,
      statusCode: statusCode,
      originalError: error,
      details: responseBody,
    );
  }
}

/// Connectivity checker helper
class ConnectivityHelper {
  static const String tag = '📡 CONNECTIVITY';

  /// Check if device can reach a host (simplified version)
  /// In a real app, use connectivity_plus package
  static Future<bool> isConnected() async {
    try {
      // Use an HTTP GET to a lightweight endpoint instead of DNS lookup
      final resp = await http
          .get(Uri.parse('https://www.google.com/generate_204'))
          .timeout(const Duration(seconds: 3));
      return resp.statusCode >= 200 && resp.statusCode < 500;
    } catch (_) {
      return false;
    }
  }

  /// Check if server is reachable
  static Future<bool> canReachServer(String apiUrl) async {
    try {
      AppLogger.debug('$tag Checking connectivity to $apiUrl');
      final uri = Uri.parse(apiUrl);
      // Prefer an HTTP GET to the server root to verify reachability
      final serverRoot = Uri(
        scheme: uri.scheme,
        host: uri.host,
        port: uri.hasPort ? uri.port : null,
        path: '/',
      );
      final resp = await http
          .get(serverRoot)
          .timeout(const Duration(seconds: 3));
      if (resp.statusCode >= 200 && resp.statusCode < 500) {
        AppLogger.info('$tag ✅ Server reachable');
        return true;
      }
      AppLogger.warning(
        '$tag ❌ Server not reachable, status=${resp.statusCode}',
      );
      return false;
    } on SocketException catch (e, stackTrace) {
      AppLogger.error('$tag ❌ Connectivity check failed: $e', e, stackTrace);
      return false;
    }
  }
}

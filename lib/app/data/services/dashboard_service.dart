import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import '../models/dashboard_api_models.dart';
import 'auth_service.dart';
import 'api_config.dart';
import 'network_error_handler.dart';
import '../../core/utils/app_logger.dart';

class DashboardService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();
  final GetStorage _storage = GetStorage();

  static String get apiBaseUrl => ApiConfig.baseUrl;

  Map<String, String> get _headers {
    final token = _authService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get comprehensive dashboard summary data for a specific language
  Future<DashboardSummary> getDashboardSummary(String languageId) async {
    final cacheKey = 'cache_dashboard_summary_$languageId';

    try {
      AppLogger.info(
        'DashboardService.getDashboardSummary(): languageId=$languageId',
      );
      return await NetworkErrorHandler.executeWithRetry(() async {
        final response = await http
            .get(
              Uri.parse(
                '$apiBaseUrl/api/dashboard/summary?language_id=$languageId',
              ),
              headers: _headers,
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          // Cache the successful response
          _storage.write(cacheKey, response.body);
          return DashboardSummary.fromJson(jsonDecode(response.body));
        } else {
          throw _handleError(response);
        }
      }, operationName: 'GetDashboardSummary');
    } catch (e) {
      // Fallback to cache on network failure
      final cachedData = _storage.read(cacheKey);
      if (cachedData != null) {
        AppLogger.warning(
          'DashboardService.getDashboardSummary(): loading dashboard summary from cache',
        );
        return DashboardSummary.fromJson(jsonDecode(cachedData));
      }
      rethrow;
    }
  }

  Exception _handleError(http.Response response) {
    try {
      final errorData = jsonDecode(response.body);
      return NetworkException(
        type: NetworkErrorHandler.detectErrorType(null, response.statusCode),
        message:
            errorData['detail'] ??
            errorData['message'] ??
            'Dashboard API Error',
        statusCode: response.statusCode,
      );
    } catch (_) {
      return NetworkException(
        type: NetworkErrorHandler.detectErrorType(null, response.statusCode),
        message: 'Request failed with status ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }
}

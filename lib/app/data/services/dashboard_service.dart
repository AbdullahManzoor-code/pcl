import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import '../models/dashboard_api_models.dart';
import '../models/analytics_model.dart';

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

  /// GET /api/user/mastery/{language_id} - Get mastery scores for all topics
  Future<List<TopicMastery>> getMasteryScores(String languageId) async {
    final cacheKey = 'cache_mastery_scores_$languageId';

    try {
      AppLogger.info(
        'DashboardService.getMasteryScores(): languageId=$languageId',
      );
      return await NetworkErrorHandler.executeWithRetry(() async {
        final response = await http
            .get(
              Uri.parse('$apiBaseUrl/api/user/mastery/$languageId'),
              headers: _headers,
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          _storage.write(cacheKey, response.body);
          final List<dynamic> data = jsonDecode(response.body);
          final masteryList = data
              .map(
                (item) => TopicMastery.fromJson(item as Map<String, dynamic>),
              )
              .toList();
          // Sort by mastery descending
          masteryList.sort((a, b) => b.mastery.compareTo(a.mastery));
          return masteryList;
        } else if (response.statusCode == 422) {
          // Invalid language ID or request parameters
          AppLogger.warning('DashboardService.getMasteryScores(): received 422 - invalid language ID or parameters');
          // Return empty list to avoid breaking UI
          return <TopicMastery>[];
        } else {
          throw _handleError(response);
        }
      }, operationName: 'GetMasteryScores');
    } catch (e) {
      final cachedData = _storage.read(cacheKey);
      if (cachedData != null) {
        AppLogger.warning(
          'DashboardService.getMasteryScores(): loading from cache',
        );
        final List<dynamic> data = jsonDecode(cachedData);
        return data
            .map((item) => TopicMastery.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      rethrow;
    }
  }

  /// GET /api/user/languages/{languageId}/progress - Get language progress
  Future<StudentProgressResponse> getLanguageProgress(String languageId) async {
    final cacheKey = 'cache_language_progress_$languageId';

    try {
      AppLogger.info(
        'DashboardService.getLanguageProgress(): languageId=$languageId',
      );
      return await NetworkErrorHandler.executeWithRetry(() async {
        final response = await http
            .get(
              Uri.parse('$apiBaseUrl/api/user/languages/$languageId/progress'),
              headers: _headers,
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          _storage.write(cacheKey, response.body);
          return StudentProgressResponse.fromJson(jsonDecode(response.body));
        } else {
          throw _handleError(response);
        }
      }, operationName: 'GetLanguageProgress');
    } catch (e) {
      final cachedData = _storage.read(cacheKey);
      if (cachedData != null) {
        AppLogger.warning(
          'DashboardService.getLanguageProgress(): loading from cache',
        );
        return StudentProgressResponse.fromJson(jsonDecode(cachedData));
      }
      rethrow;
    }
  }

  // Removed getActiveTransferBoosts – no corresponding API endpoint required.

  /// GET /api/synergy/recent-bonuses - Get recent synergy bonuses
  Future<List<SynergyBonus>> getRecentSynergyBonuses(
    String languageId, {
    int days = 7,
  }) async {
    return NetworkErrorHandler.executeWithRetry(() async {
      final response = await http
          .get(
            Uri.parse(
              '$apiBaseUrl/api/synergy/recent-bonuses?language_id=$languageId&days=$days',
            ),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => SynergyBonus.fromJson(item)).toList();
      } else {
        throw _handleError(response);
      }
    }, operationName: 'GetRecentSynergyBonuses');
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

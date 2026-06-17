import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import '../models/course_api_models.dart';
import 'auth_service.dart';
import 'api_config.dart';
import 'network_error_handler.dart';
import '../../core/utils/app_logger.dart';

class CourseService extends GetxService {
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

  /// Get user's complete language learning portfolio
  Future<LanguagePortfolio> getUserLanguages() async {
    const cacheKey = 'cache_user_languages';
    try {
      AppLogger.info(
        'CourseService.getUserLanguages(): loading user languages',
      );
      return await NetworkErrorHandler.executeWithRetry(() async {
        final response = await http
            .get(Uri.parse('$apiBaseUrl/api/user/languages'), headers: _headers)
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          _storage.write(cacheKey, response.body);
          return LanguagePortfolio.fromJson(jsonDecode(response.body));
        } else {
          throw _handleError(response);
        }
      }, operationName: 'GetUserLanguages');
    } catch (e) {
      final cachedData = _storage.read(cacheKey);
      if (cachedData != null) {
        AppLogger.warning(
          'CourseService.getUserLanguages(): loading user languages from cache',
        );
        return LanguagePortfolio.fromJson(jsonDecode(cachedData));
      }
      rethrow;
    }
  }

  /// Add a new language to user's learning path
  Future<void> enrollInLanguage(String languageId, String difficulty) async {
    AppLogger.info(
      'CourseService.enrollInLanguage(): languageId=$languageId, difficulty=$difficulty',
    );
    return NetworkErrorHandler.executeWithRetry(() async {
      final response = await http
          .post(
            Uri.parse('$apiBaseUrl/api/user/languages'),
            headers: _headers,
            body: jsonEncode({
              'language_id': languageId,
              'difficulty_level': difficulty,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw _handleError(response);
      }
    }, operationName: 'EnrollInLanguage');
  }

  /// Fetch full curriculum data
  Future<List<LanguageCurriculum>> getCurriculum() async {
    const cacheKey = 'cache_curriculum_all';
    try {
      AppLogger.info('CourseService.getCurriculum(): loading curriculum');
      return await NetworkErrorHandler.executeWithRetry(() async {
        final response = await http
            .get(Uri.parse('$apiBaseUrl/curriculum/all'), headers: _headers)
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          _storage.write(cacheKey, response.body);
          final List<dynamic> data = jsonDecode(response.body);
          return data.map((json) => LanguageCurriculum.fromJson(json)).toList();
        } else {
          throw _handleError(response);
        }
      }, operationName: 'GetCurriculum');
    } catch (e) {
      final cachedData = _storage.read(cacheKey);
      if (cachedData != null) {
        AppLogger.warning(
          'CourseService.getCurriculum(): loading curriculum from cache',
        );
        final List<dynamic> data = jsonDecode(cachedData);
        return data.map((json) => LanguageCurriculum.fromJson(json)).toList();
      }
      rethrow;
    }
  }

  /// Get student progress for a specific language
  Future<StudentProgressResponse> getLanguageProgress(String languageId) async {
    final cacheKey = 'cache_language_progress_$languageId';
    try {
      AppLogger.info(
        'CourseService.getLanguageProgress(): languageId=$languageId',
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
          'CourseService.getLanguageProgress(): loading cached progress for $languageId',
        );
        return StudentProgressResponse.fromJson(jsonDecode(cachedData));
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
            errorData['detail'] ?? errorData['message'] ?? 'Course API Error',
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

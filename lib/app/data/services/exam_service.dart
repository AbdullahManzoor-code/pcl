import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pcl/app/core/utils/app_logger.dart';
import 'dart:convert';
import 'dart:async';

import '../models/exam_api_models.dart';
import 'auth_service.dart';
import 'api_config.dart';
import 'network_error_handler.dart';

class ExamService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();

  static String get apiBaseUrl => ApiConfig.baseUrl;

  Map<String, String> get _headers {
    final token = _authService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<ExamStartResponse> startExamSession(ExamStartRequest request) async {
    return NetworkErrorHandler.executeWithRetry(() async {
      final response = await http
          .post(
            Uri.parse('$apiBaseUrl/api/exam/start'),
            headers: _headers,
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ExamStartResponse.fromJson(jsonDecode(response.body));
      } else {
        throw _handleError(response);
      }
    }, operationName: 'StartExamSession');
  }

  Future<SelectQuestionsResponse> selectQuestions(
    SelectQuestionsRequest request,
  ) async {
    return NetworkErrorHandler.executeWithRetry(() async {
      final response = await http
          .post(
            Uri.parse('$apiBaseUrl/question-bank/select'),
            headers: _headers,
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 15)); // RL might take longer

      if (response.statusCode == 200) {
        return SelectQuestionsResponse.fromJson(jsonDecode(response.body));
      } else {
        throw _handleError(response);
      }
    }, operationName: 'SelectQuestions');
  }

  Future<SelectQuestionsResponse> pollNewQuestions(String sessionId) async {
    return NetworkErrorHandler.executeWithRetry(() async {
      final response = await http
          .get(
            Uri.parse('$apiBaseUrl/question-bank/poll/$sessionId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return SelectQuestionsResponse.fromJson(jsonDecode(response.body));
      } else {
        throw _handleError(response);
      }
    }, operationName: 'PollNewQuestions');
  }

  Future<ExamSubmissionResponse> submitExam(
    ExamSubmissionPayload payload,
  ) async {
    return NetworkErrorHandler.executeWithRetry(() async {
      // Log the outgoing payload for debugging server-side 422s
      AppLogger.debug(
        'ExamService.submitExam(): payload=${jsonEncode(payload.toSubmitJson())}',
      );
      final response = await http
          .post(
            Uri.parse('$apiBaseUrl/api/exam/submit'),
            headers: _headers,
            body: jsonEncode(payload.toSubmitJson()),
          )
          .timeout(const Duration(seconds: 15));
      AppLogger.debug(
        'ExamService.submitExam(): responseStatus=${response.statusCode}',
      );

      if (response.statusCode == 200) {
        return ExamSubmissionResponse.fromJson(jsonDecode(response.body));
      } else {
        AppLogger.debug(
          'ExamService.submitExam(): responseBody=${response.body}',
        );
        throw _handleError(response);
      }
    }, operationName: 'SubmitExam');
  }

  Future<ExamResultsResponse> getExamResults(String sessionId) async {
    return NetworkErrorHandler.executeWithRetry(() async {
      final response = await http
          .get(
            Uri.parse('$apiBaseUrl/api/exam/results/$sessionId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return ExamResultsResponse.fromJson(jsonDecode(response.body));
      } else {
        throw _handleError(response);
      }
    }, operationName: 'GetExamResults');
  }

  Future<SessionHistoryResponse> getExamHistory({
    String? languageId,
    String? sessionType,
    int limit = 10,
    int offset = 0,
  }) async {
    return NetworkErrorHandler.executeWithRetry(() async {
      final queryParams = <String, String>{};
      if (languageId != null) queryParams['language_id'] = languageId;
      if (sessionType != null) queryParams['session_type'] = sessionType;
      queryParams['limit'] = limit.toString();
      queryParams['offset'] = offset.toString();

      final uri = Uri.parse(
        '$apiBaseUrl/api/sessions/history',
      ).replace(queryParameters: queryParams);

      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return SessionHistoryResponse.fromJson(jsonDecode(response.body));
      } else {
        throw _handleError(response);
      }
    }, operationName: 'GetExamHistory');
  }

  Exception _handleError(http.Response response) {
    try {
      final errorData = jsonDecode(response.body);
      return NetworkException(
        type: NetworkErrorHandler.detectErrorType(null, response.statusCode),
        message:
            errorData['detail'] ?? errorData['message'] ?? 'Exam API Error',
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

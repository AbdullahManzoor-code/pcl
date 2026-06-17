import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pcl/app/core/utils/app_logger.dart';

import '../models/report_models.dart';
import 'auth_service.dart';
import 'api_config.dart';
import 'network_error_handler.dart';

class ReportsService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();

  static String get apiBaseUrl => ApiConfig.baseUrl;

  Map<String, String> get _headers {
    final token = _authService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<QuestionReportResponse> createReport(
    CreateQuestionReportRequest req,
  ) async {
    return NetworkErrorHandler.executeWithRetry(() async {
      AppLogger.debug(
        'ReportsService.createReport(): payload=${jsonEncode(req.toJson())}',
      );
      final response = await http
          .post(
            Uri.parse('$apiBaseUrl/api/reports'),
            headers: _headers,
            body: jsonEncode(req.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return QuestionReportResponse.fromJson(jsonDecode(response.body));
      } else {
        AppLogger.debug(
          'ReportsService.createReport(): responseBody=${response.body}',
        );
        throw _handleError(response);
      }
    }, operationName: 'CreateReport');
  }

  Future<List<QuestionReportResponse>> getUserReports({
    String? sessionId,
  }) async {
    return NetworkErrorHandler.executeWithRetry(() async {
      final endpoint = sessionId != null
          ? Uri.parse('$apiBaseUrl/api/reports/user?session_id=$sessionId')
          : Uri.parse('$apiBaseUrl/api/reports/user');

      final response = await http
          .get(endpoint, headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List;
        return list.map((e) => QuestionReportResponse.fromJson(e)).toList();
      } else {
        throw _handleError(response);
      }
    }, operationName: 'GetUserReports');
  }

  Exception _handleError(http.Response response) {
    try {
      final errorData = jsonDecode(response.body);
      return NetworkException(
        type: NetworkErrorHandler.detectErrorType(null, response.statusCode),
        message:
            errorData['detail'] ?? errorData['message'] ?? 'Reports API Error',
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

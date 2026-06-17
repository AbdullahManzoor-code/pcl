import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/services/reports_service.dart';
import '../../../data/models/report_models.dart';
import '../../../data/services/auth_service.dart';
import '../../../core/utils/app_logger.dart';

class ReportsController extends GetxController {
  final ReportsService _reportsService = Get.find<ReportsService>();
  final AuthService _authService = Get.find<AuthService>();

  final reports = <QuestionReportResponse>[].obs;
  final isLoading = false.obs;

  final reportType = 'other'.obs;
  final description = ''.obs;
  final sessionId = RxnString();
  final questionId = RxnString();

  @override
  void onInit() {
    super.onInit();
    // Prefill question id from arguments when navigating from question card
    final args = Get.arguments;
    if (args != null && args is Map && args['questionId'] != null) {
      questionId.value = args['questionId'].toString();
    }
    loadUserReports();
  }

  Future<void> loadUserReports() async {
    try {
      isLoading.value = true;
      final res = await _reportsService.getUserReports(
        sessionId: sessionId.value,
      );
      reports.assignAll(res);
    } catch (e, st) {
      AppLogger.error('ReportsController.loadUserReports(): failed', e, st);
      Get.snackbar('Error', 'Failed to load reports');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitReport(String? passedQuestionId) async {
    try {
      isLoading.value = true;
      final qid = passedQuestionId ?? questionId.value;
      if (qid == null || qid.isEmpty) {
        Get.snackbar('Missing Question', 'Question ID is required to report.');
        return;
      }
      final req = CreateQuestionReportRequest(
        questionId: qid,
        sessionId: null,
        reportType: reportType.value,
        description: description.value,
      );
      final created = await _reportsService.createReport(req);
      reports.insert(0, created);
      Get.snackbar('Reported', 'Thank you for your report');
    } catch (e, st) {
      AppLogger.error('ReportsController.submitReport(): failed', e, st);
      Get.snackbar('Error', 'Failed to submit report');
    } finally {
      isLoading.value = false;
    }
  }
}

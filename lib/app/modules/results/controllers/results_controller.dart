import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/models/exam_api_models.dart';
import '../../../data/services/exam_service.dart';
import '../../../core/utils/haptic_utils.dart';

class ResultsController extends GetxController {
  final ExamService _examService = Get.find<ExamService>();

  final isLoading = true.obs;
  final score = 0.obs;
  final totalQuestions = 0.obs;
  final correctAnswers = 0.obs;
  final incorrectAnswers = 0.obs;
  final percentage = 0.0.obs;
  final timeTaken = '---'.obs;
  final analysisStatus = 'unknown'.obs;
  final overallReadiness = RxnDouble();

  final courseId = ''.obs;
  final conceptName = ''.obs;
  final userRating = 5.0.obs;
  final userComment = ''.obs;
  final isReviewSubmitted = false.obs;

  // Analysis Data
  final questions = <QuestionResultPayload>[].obs;
  final strongTopics = <StrongTopic>[].obs;
  final errorPatterns = <EnhancedErrorPattern>[].obs;
  final recommendations = <EnhancedRecommendation>[].obs;
  final prerequisiteGaps = <PrerequisiteGap>[].obs;
  final recommendationsSource = ''.obs;
  final errorPatternsSource = ''.obs;

  double _normalizePercent(double value) {
    if (value <= 1.0) {
      return value * 100.0;
    }
    return value;
  }

  @override
  void onInit() {
    super.onInit();
    AppLogger.info(
      'ResultsController.onInit(): reading result session arguments',
    );

    if (Get.arguments != null && Get.arguments is String) {
      final sessionId = Get.arguments as String;
      AppLogger.info(
        'ResultsController.onInit(): loading sessionId=$sessionId',
      );
      _loadResults(sessionId);
    } else {
      AppLogger.warning(
        'ResultsController.onInit(): missing sessionId, returning',
      );
      Get.back();
    }
  }

  Future<void> _loadResults(String sessionId) async {
    AppLogger.info('ResultsController._loadResults(): sessionId=$sessionId');
    isLoading.value = true;
    try {
      final result = await _examService.getExamResults(sessionId);

      courseId.value = result.languageId;
      conceptName.value =
          result.majorTopicId.capitalizeFirst ?? result.majorTopicId;

      totalQuestions.value = result.questions.length;
      correctAnswers.value = result.questions.where((q) => q.isCorrect).length;
      incorrectAnswers.value = totalQuestions.value - correctAnswers.value;

      final backendScorePercent = _normalizePercent(
        result.overallScore,
      ).clamp(0.0, 100.0);
      score.value = correctAnswers.value;
      percentage.value = _normalizePercent(result.accuracy).clamp(0.0, 100.0);

      final mins = (result.timeTakenSeconds / 60).floor();
      final secs = result.timeTakenSeconds % 60;
      timeTaken.value =
          '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

      questions.value = result.questions;
      strongTopics.value = result.strongTopics;
      errorPatterns.value = result.errorPatterns;
      recommendations.value = result.recommendations;
      prerequisiteGaps.value = result.prerequisiteGaps;
      analysisStatus.value = result.analysisStatus;
      overallReadiness.value = result.overallReadiness;
      recommendationsSource.value = result.recommendationsSource ?? 'unknown';
      errorPatternsSource.value = result.errorPatternsSource ?? 'unknown';
      AppLogger.info(
        'ResultsController._loadResults(): questions=${result.questions.length}, backendScore=${result.overallScore}, accuracy=${result.accuracy}, score=${score.value}, percentage=${percentage.value}, analysis=${analysisStatus.value}',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'ResultsController._loadResults(): failed',
        e,
        stackTrace,
      );
      Get.snackbar('Error', 'Could not load exam results analysis.');
    } finally {
      isLoading.value = false;
    }
  }

  String _calculateGrade(double p) {
    if (p >= 90) return 'A+';
    if (p >= 80) return 'A';
    if (p >= 70) return 'B';
    if (p >= 60) return 'C';
    return 'D';
  }

  String get grade =>
      _calculateGrade(_normalizePercent(percentage.value).clamp(0.0, 100.0));

  void submitReview() {
    if (courseId.value.isEmpty) return;

    // Validation
    if (userRating.value <= 3 && userComment.value.trim().isEmpty) {
      AppLogger.warning(
        'ResultsController.submitReview(): comment required for low rating',
      );
      Get.snackbar(
        'Attention',
        'Please let us know how we can improve in your comments.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
      return;
    }

    // Process
    isReviewSubmitted.value = true;
    AppLogger.info(
      'ResultsController.submitReview(): feedback submitted rating=${userRating.value}',
    );
    Get.snackbar(
      'Success',
      'Thank you for your feedback!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
    );
  }

  void handlePracticeAgain() {
    AppLogger.info(
      'ResultsController.handlePracticeAgain(): courseId=${courseId.value}',
    );
    Get.offNamed(Routes.quiz, arguments: courseId.value);
  }

  void practiceTopic(String topicName) {
    AppLogger.info('ResultsController.practiceTopic(): topicName=$topicName');
    HapticUtils.mediumImpact();
    // Navigate to PracticeView with the specific topic pre-selected
    Get.toNamed(Routes.practice, arguments: {'concept': topicName});
  }

  void downloadCertificate() {
    // HapticUtils.selectionChange();
    // TODO: Connect to backend PDF endpoint when available
    // For now, we mock the download response
    AppLogger.info('ResultsController.downloadCertificate(): tapped');
    Get.snackbar(
      'Certificate Downloaded',
      'Your certificate of mastery has been saved to your device.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
      icon: Icon(Icons.check_circle, color: Colors.green.shade900),
    );
  }

  void goToDashboard() {
    AppLogger.info(
      'ResultsController.goToDashboard(): returning to main shell',
    );
    Get.offAllNamed(Routes.main);
  }
}

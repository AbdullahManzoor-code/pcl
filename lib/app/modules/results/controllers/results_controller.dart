import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../data/models/quiz_model.dart';
import '../../../data/models/test_result_model.dart';
import '../../../core/utils/haptic_utils.dart';

class ResultsController extends GetxController {
  final score = 0.obs;
  final totalQuestions = 0.obs;
  final correctAnswers = 0.obs;
  final incorrectAnswers = 0.obs;
  final percentage = 0.0.obs;
  final grade = 'F'.obs;
  final timeTaken = '---'.obs;

  final courseId = ''.obs;
  final conceptName = ''.obs;
  final userRating = 5.0.obs;
  final userComment = ''.obs;
  final isReviewSubmitted = false.obs;

  // Data passed from Quiz
  final questions = <Question>[].obs;
  final answers = <int, dynamic>{}.obs;

  // Analysis Data
  final strongTopics = <Map<String, dynamic>>[].obs;
  final weakTopics = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null && Get.arguments is TestResult) {
      final result = Get.arguments as TestResult;

      // Basic Stats
      score.value = result.score;
      totalQuestions.value = result.totalQuestions;
      courseId.value = result.conceptId;
      conceptName.value = result.conceptName;
      percentage.value = result.accuracy.toDouble();

      questions.value = result.questions;
      answers.value = result.answers;

      // Derived Stats
      correctAnswers.value = score.value;
      incorrectAnswers.value = totalQuestions.value - correctAnswers.value;
      grade.value = _calculateGrade(percentage.value);

      // Mock Analysis Generation
      _generateMockAnalysis();
    }
  }

  String _calculateGrade(double p) {
    if (p >= 90) return 'A+';
    if (p >= 80) return 'A';
    if (p >= 70) return 'B';
    if (p >= 60) return 'C';
    return 'D';
  }

  void _generateMockAnalysis() {
    // In a real app, we'd analyze which topics the correct/incorrect questions belong to.
    // For this prototype, we'll generate static data to match the UI.
    strongTopics.value = [
      {'name': 'Variables & Data Types', 'accuracy': 95},
      {'name': 'Control Flow', 'accuracy': 90},
    ];
    weakTopics.value = [
      {'name': 'Functions', 'accuracy': 65},
      {'name': 'Object-Oriented Programming', 'accuracy': 55},
    ];
  }

  void submitReview() {
    if (courseId.value.isEmpty) return;

    // Validation
    if (userRating.value <= 3 && userComment.value.trim().isEmpty) {
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
    Get.snackbar(
      'Success',
      'Thank you for your feedback!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
    );
  }

  void handlePracticeAgain() {
    Get.offNamed(Routes.quiz, arguments: courseId.value);
  }

  void practiceTopic(String topicName) {
    HapticUtils.mediumImpact();
    // Navigate to PracticeView with the specific topic pre-selected
    Get.toNamed(Routes.practice, arguments: {'concept': topicName});
  }

  void goToDashboard() {
    Get.offAllNamed(Routes.main);
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../data/repositories/course_repository.dart';
import '../../../data/services/mock_api_service.dart';

class ResultsController extends GetxController {
  late final CourseRepository _courseRepository;

  final score = 0.obs;
  final totalQuestions = 0.obs;
  final correctAnswers = 0.obs;
  final incorrectAnswers = 0.obs;

  final courseId = ''.obs;
  final userRating = 5.0.obs;
  final userComment = ''.obs;
  final isReviewSubmitted = false.obs;

  // AI / ML Results
  final xpEarned = 0.obs;
  final mlRecommendation = ''.obs;
  final mlNextAction = ''.obs;
  final mlConfidence = 0.0.obs;
  final strength = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _courseRepository = CourseRepositoryImpl(Get.find<MockApiService>());

    if (Get.arguments != null) {
      final args = Get.arguments as Map<String, dynamic>;
      totalQuestions.value = args['total'] ?? 0;
      correctAnswers.value = args['correct'] ?? 0;
      incorrectAnswers.value = args['incorrect'] ?? 0;
      courseId.value = args['courseId'] ?? '';

      if (totalQuestions.value > 0) {
        score.value =
            args['score'] ??
            ((correctAnswers.value / totalQuestions.value) * 100).toInt();
      }

      // Extract ML Data
      xpEarned.value = args['xp_earned'] ?? 0;
      if (args['ml_analysis'] != null) {
        final ml = args['ml_analysis'] as Map<String, dynamic>;
        mlRecommendation.value = ml['recommendation'] ?? '';
        mlNextAction.value = ml['next_action'] ?? '';
        mlConfidence.value = (ml['confidence_score'] ?? 0.0).toDouble();
        strength.value = ml['strength'] ?? '';
      }
    }
  }

  void submitReview() {
    if (courseId.value.isEmpty) return;

    // Validation: Require a comment if rating is <= 3
    if (userRating.value <= 3 && userComment.value.trim().isEmpty) {
      Get.snackbar(
        'Attention',
        'Please let us know how we can improve in your comments.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
      );
      return;
    }

    try {
      final review = {
        'id': 'r${DateTime.now().millisecondsSinceEpoch}',
        'user_name': 'Mian',
        'user_avatar': '',
        'rating': userRating.value,
        'comment': userComment.value.isEmpty
            ? 'Great lesson!'
            : userComment.value.trim(),
        'date': DateTime.now().toIso8601String(),
      };

      _courseRepository.addReview(courseId.value, review);
      isReviewSubmitted.value = true;

      Get.snackbar(
        'Success',
        'Thank you for your feedback!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit review. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
      );
    }
  }

  void navigateToNextAction() {
    if (courseId.value.isEmpty) return;

    // In this mock flow, we navigate back to Course Details to continue
    // Better experience: go to the specific topic, but for now CourseDetails is the hub.
    Get.snackbar(
      'Continuing Path',
      'Heading back to the course to continue...',
    );
    Get.offNamed(Routes.COURSE_DETAILS, arguments: courseId.value);
  }

  void goToDashboard() {
    Get.offAllNamed(Routes.MAIN);
  }
}

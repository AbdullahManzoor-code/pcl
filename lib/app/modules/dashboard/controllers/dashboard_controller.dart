import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcl/app/core/theme/app_theme.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/analytics_model.dart';
import '../../../data/repositories/course_repository.dart';
import '../../../data/services/mock_api_service.dart';
import '../../../routes/app_pages.dart';

class DashboardController extends GetxController {
  final CourseRepository _courseRepository = Get.find<CourseRepository>();

  final stats = <String, dynamic>{}.obs;
  final enrolledCourses = <Course>[].obs;
  final completedCourses = <Course>[].obs;
  final recommendedCourses = <Course>[].obs;
  final isLoading = true.obs;
  final aiEvaluation = <String, dynamic>{}.obs;
  final recommendedTopic = Rxn<RecommendedTopic>();

  // Creation States
  final selectedLanguage = 'Python'.obs;
  final selectedDifficulty = 'Medium'.obs;
  final isCreating = false.obs;

  final languages = [
    {'name': 'Python', 'icon': '🐍'},
    {'name': 'JavaScript', 'icon': '📜'},
    {'name': 'C++', 'icon': '⚙️'},
    {'name': 'Java', 'icon': '☕'},
    {'name': 'TypeScript', 'icon': '📘'},
    {'name': 'Go', 'icon': '🐹'},
  ];

  final difficulties = ['Easy', 'Medium', 'Hard'];

  @override
  void onInit() {
    super.onInit();
    fetchData();

    // Listen to global course changes for instant sync
    final service = Get.find<MockApiService>();
    ever(service.courses, (_) => fetchData());
  }

  void fetchData() async {
    isLoading.value = true;
    try {
      final service = Get.find<MockApiService>();
      stats.assignAll(service.getUserStats());

      enrolledCourses.value = _courseRepository.getEnrolledCourses();
      completedCourses.value = _courseRepository.getCompletedCourses();
      recommendedCourses.value = _courseRepository.getRecommendedCourses();

      if (service.lastEvaluation.isNotEmpty) {
        aiEvaluation.assignAll(service.lastEvaluation);
      }

      final recommendationData = service.getAIRecommendation('python');
      recommendedTopic.value = RecommendedTopic.fromJson(recommendationData);
    } catch (e) {
      print('Error fetching dashboard data: $e');
      Get.snackbar(
        'Error',
        'Could not load your dashboard data. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToRecommendation() {
    try {
      final rec = recommendedTopic.value;
      if (rec == null) {
        Get.snackbar(
          'Info',
          'No recommendation available at the moment.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Navigate to practice with pre-selected concept
      Get.toNamed(
        Routes.practice,
        arguments: {
          'conceptId': rec.conceptId,
          'conceptName': rec.conceptName,
          'subTopic': rec.subTopic,
        },
      );
    } catch (e) {
      print('Error navigating to recommendation: $e');
      Get.snackbar(
        'Error',
        'Could not navigate to practice. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
    }
  }

  void openCourse(Course course) {
    // Navigate with model. Arguments can be the model object.
    // Ensure receiver handles it.
    Get.toNamed(
      Routes.courseDetails,
      arguments: {'course': course},
    ); // Fixed arguments format
  }

  void createLearningPath() async {
    isCreating.value = true;
    try {
      await Future.delayed(const Duration(seconds: 1)); // Mock API delay

      final service = Get.find<MockApiService>();

      // Determine next ID
      final newId = 'c_${service.courses.length + 1}';

      // Create new course model
      final newCourse = Course(
        id: newId,
        title: selectedLanguage.value,
        level: selectedDifficulty.value,
        progress: 0.0,
        totalTopics: 10, // Mock default
        topicsCompleted: 0,
        accuracy: 0,
        lastActivity: 'Just now',
        isEnrolled: true, // IMPORTANT: Must be true to show on dashboard
        image:
            'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/${selectedLanguage.value.toLowerCase()}/${selectedLanguage.value.toLowerCase()}-original.svg',
        description:
            'Master ${selectedLanguage.value} programming from basic to advanced concepts.',
        category: selectedLanguage.value,
        topics: [], // Initialize topics
      );

      // Add to repository/service
      service.courses.add(newCourse.toJson());
      // Note: Changes are auto-persisted via reactive storage

      // Refresh dashboard
      fetchData();

      Get.snackbar(
        'Success',
        'Started new learning path: ${selectedLanguage.value}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withOpacity(0.1),
        colorText: AppColors.success,
        icon: const Icon(Icons.check_circle_outline, color: AppColors.success),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create learning path. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
        icon: const Icon(Icons.error_outline, color: AppColors.error),
      );
      print('Error creating learning path: $e');
    } finally {
      isCreating.value = false;
    }
  }
}

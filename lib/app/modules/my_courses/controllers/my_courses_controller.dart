import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/models/course_model.dart';
import '../../../data/services/course_service.dart';
import '../../../data/services/course_api_adapter.dart';
import '../../../data/services/network_error_handler.dart';
import '../../courses/controllers/courses_controller.dart';

class MyCoursesController extends GetxController {
  final _courseService = Get.find<CourseService>();

  final enrolledCourses = <Course>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('MyCoursesController.onInit(): loading enrolled courses');
    fetchEnrolledCourses();
  }

  void fetchEnrolledCourses() async {
    AppLogger.info('MyCoursesController.fetchEnrolledCourses(): start');
    isLoading.value = true;
    try {
      final portfolio = await _courseService.getUserLanguages();
      final courses = portfolio.languages
          .map((stat) => CourseApiAdapter.mapLanguageStatsToCourse(stat))
          .toList();
      enrolledCourses.assignAll(courses);
      AppLogger.info(
        'MyCoursesController.fetchEnrolledCourses(): loaded ${courses.length} courses',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'MyCoursesController.fetchEnrolledCourses(): failed',
        e,
        stackTrace,
      );
      Get.snackbar(
        'Error',
        'Failed to load your courses.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void refreshCourses() => fetchEnrolledCourses();

  // Creation States
  final selectedLanguage = 'Python'.obs;
  final isCreating = false.obs;

  final languages = [
    {'name': 'Python', 'id': 'python_3', 'icon': '🐍'},
    {'name': 'JavaScript', 'id': 'javascript_es6', 'icon': '📜'},
    {'name': 'C++', 'id': 'cpp_20', 'icon': '⚙️'},
    {'name': 'Java', 'id': 'java_17', 'icon': '☕'},
    {'name': 'TypeScript', 'id': 'typescript_5', 'icon': '📘'},
    {'name': 'Go', 'id': 'go_1_21', 'icon': '🐹'},
  ];

  final creationDifficulties = ['Easy', 'Medium', 'Hard'];
  final creationSelectedDifficulty = 'Medium'.obs;

  void createLearningPath() async {
    AppLogger.info('MyCoursesController.createLearningPath(): submitted');
    isCreating.value = true;
    try {
      final langItem = languages.firstWhere(
        (l) => l['name'] == selectedLanguage.value,
        orElse: () => languages.first,
      );

      final languageId = langItem['id']!;
      final difficulty = creationSelectedDifficulty.value.toLowerCase();

      // Check if already enrolled
      if (enrolledCourses.any((c) => c.id == languageId)) {
        Get.snackbar(
          'Already Enrolled',
          'You are already enrolled in ${selectedLanguage.value}.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF3B82F6).withOpacity(0.1),
          colorText: const Color(0xFF3B82F6),
        );
        isCreating.value = false;
        return;
      }

      // Call API
      await _courseService.enrollInLanguage(languageId, difficulty);

      // Refresh courses list from API
      fetchEnrolledCourses();

      // Refresh CoursesController if registered to sync state immediately
      try {
        if (Get.isRegistered<CoursesController>()) {
          Get.find<CoursesController>().fetchCourses();
        }
      } catch (e) {
        AppLogger.warning(
          'MyCoursesController.createLearningPath(): failed to refresh CoursesController',
          e,
        );
      }

      AppLogger.info(
        'MyCoursesController.createLearningPath(): success language=${selectedLanguage.value}',
      );
      Get.snackbar(
        'Success',
        'Started new learning path: ${selectedLanguage.value}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF22C55E).withOpacity(0.1),
        colorText: const Color(0xFF22C55E),
        icon: const Icon(Icons.check_circle_outline, color: Color(0xFF22C55E)),
      );
    } on NetworkException catch (e, stackTrace) {
      AppLogger.error(
        'MyCoursesController.createLearningPath(): network failure',
        e,
        stackTrace,
      );
      Get.snackbar(
        'Error',
        e.getUserMessage(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444).withOpacity(0.1),
        colorText: const Color(0xFFEF4444),
        icon: const Icon(Icons.error_outline, color: Color(0xFFEF4444)),
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'MyCoursesController.createLearningPath(): failed',
        e,
        stackTrace,
      );
      Get.snackbar(
        'Error',
        'Failed to create learning path. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444).withOpacity(0.1),
        colorText: const Color(0xFFEF4444),
        icon: const Icon(Icons.error_outline, color: Color(0xFFEF4444)),
      );
    } finally {
      isCreating.value = false;
    }
  }
}

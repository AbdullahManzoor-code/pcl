import 'package:get/get.dart';
import 'package:pcl/app/modules/my_courses/controllers/my_courses_controller.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/course_api_models.dart';
import '../../../data/services/course_service.dart';
import '../../../data/services/course_api_adapter.dart';
import '../../../data/services/network_error_handler.dart';
import '../../../routes/app_pages.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CoursesController extends GetxController {
  final _courseService = Get.find<CourseService>();

  final courses = <Course>[].obs;
  final isLoading = true.obs;
  final isGridView = true.obs;

  // Search and Filter
  final searchText = ''.obs;
  final selectedCategory = 'All'.obs;
  final selectedDifficulty = 'All'.obs;
  final sortBy = 'Name'.obs; // Name, Progress, Rating
  final categories = <String>['All'].obs;
  final difficulties = <String>['All', 'Easy', 'Medium', 'Hard'].obs;
  final sortOptions = <String>['Name', 'Progress', 'Rating'].obs;

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

  final creationDifficulties = ['Beginner', 'Intermediate', 'Advanced'];
  final creationSelectedDifficulty = 'Beginner'.obs;

  final creationIntensities = ['Casual', 'Regular', 'Intense'];
  final creationSelectedIntensity = 'Regular'.obs;

  void createLearningPath() async {
    AppLogger.info('CoursesController.createLearningPath(): submitted');
    isCreating.value = true;
    try {
      final langItem = languages.firstWhere(
        (l) => l['name'] == selectedLanguage.value,
        orElse: () => languages.first,
      );

      final languageId = langItem['id']!;
      final difficulty = creationSelectedDifficulty.value.toLowerCase();

      // Check if already enrolled
      try {
        final portfolio = await _courseService.getUserLanguages();
        if (portfolio.languages.any((l) => l.languageId == languageId)) {
          Get.snackbar(
            'Already Enrolled',
            'You are already enrolled in ${selectedLanguage.value}.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            colorText: AppColors.primary,
          );
          isCreating.value = false;
          return;
        }
      } catch (_) {
        // Ignore cache fetch error, let the API call fail if needed
      }

      await _courseService.enrollInLanguage(languageId, difficulty);

      // Refresh courses list
      fetchCourses();

      // Refresh MyCoursesController if registered to sync state immediately
      try {
        if (Get.isRegistered<MyCoursesController>()) {
          Get.find<MyCoursesController>().fetchEnrolledCourses();
        }
      } catch (e) {
        AppLogger.warning(
          'CoursesController.createLearningPath(): failed to refresh MyCoursesController',
          e,
        );
      }

      Get.snackbar(
        'Success',
        'Started new learning path: ${selectedLanguage.value}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withOpacity(0.1),
        colorText: AppColors.success,
        icon: const Icon(Icons.check_circle_outline, color: AppColors.success),
      );
      AppLogger.info(
        'CoursesController.createLearningPath(): success language=${selectedLanguage.value}',
      );
    } on NetworkException catch (e, stackTrace) {
      Get.snackbar(
        'Error',
        e.getUserMessage(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
        icon: const Icon(Icons.error_outline, color: AppColors.error),
      );
      AppLogger.error(
        'CoursesController.createLearningPath(): network failure',
        e,
        stackTrace,
      );
    } catch (e, stackTrace) {
      Get.snackbar(
        'Error',
        'Failed to create learning path. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
        icon: const Icon(Icons.error_outline, color: AppColors.error),
      );
      AppLogger.error(
        'CoursesController.createLearningPath(): failed',
        e,
        stackTrace,
      );
    } finally {
      isCreating.value = false;
    }
  }

  List<Course> get filteredCourses {
    var filtered = courses.where((course) {
      final query = searchText.value.trim().toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          course.title.toLowerCase().contains(query) ||
          course.description.toLowerCase().contains(query);

      final category = selectedCategory.value;
      final matchesCategory =
          category == 'All' ||
          course.category.toLowerCase() == category.toLowerCase();

      final difficulty = selectedDifficulty.value;
      final matchesDifficulty =
          difficulty == 'All' ||
          course.level.toLowerCase() == difficulty.toLowerCase();

      return matchesSearch && matchesCategory && matchesDifficulty;
    }).toList();

    // Apply sorting
    switch (sortBy.value) {
      case 'Progress':
        filtered.sort((a, b) => b.progress.compareTo(a.progress));
        break;
      case 'Rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Name':
      default:
        filtered.sort((a, b) => a.title.compareTo(b.title));
    }

    return filtered;
  }

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('CoursesController.onInit(): loading courses');
    fetchCourses();
  }

  void fetchCourses() async {
    AppLogger.info('CoursesController.fetchCourses(): start');
    isLoading.value = true;
    try {
      // For all available courses, fetch curriculum roadmap
      final curriculums = await _courseService.getCurriculum();

      // Fetch user portfolio if available to see which courses they are enrolled in
      LanguagePortfolio? portfolio;
      try {
        portfolio = await _courseService.getUserLanguages();
      } catch (e) {
        AppLogger.warning(
          'CoursesController.fetchCourses(): failed to load user portfolio',
          e,
        );
      }

      final allCourses = curriculums.map((c) {
        final course = CourseApiAdapter.mapCurriculumToCourse(c);
        if (portfolio != null) {
          final stats = portfolio.languages.firstWhereOrNull(
            (l) => l.languageId == course.id,
          );
          if (stats != null) {
            final mapped = CourseApiAdapter.mapLanguageStatsToCourse(stats);
            return mapped.copyWith(
              level: course.level,
              description: course.description,
              rating: course.rating,
              reviewCount: course.reviewCount,
              totalTopics: course.totalTopics,
            );
          }
        }
        return course;
      }).toList();

      courses.assignAll(allCourses);

      // Extract unique categories
      final distinctCategories = allCourses
          .map((c) => c.category)
          .toSet()
          .toList();
      categories.assignAll(['All', ...distinctCategories]);
      AppLogger.info(
        'CoursesController.fetchCourses(): loaded courses=${allCourses.length}',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'CoursesController.fetchCourses(): failed',
        e,
        stackTrace,
      );
      Get.snackbar(
        'Error',
        'Failed to load courses. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void toggleView() {
    AppLogger.debug(
      'CoursesController.toggleView(): grid=${!isGridView.value}',
    );
    isGridView.value = !isGridView.value;
    HapticUtils.selectionClick();
  }

  void openCourse(Course course) {
    AppLogger.info('CoursesController.openCourse(): courseId=${course.id}');
    HapticUtils.lightImpact();
    Get.toNamed(Routes.courseDetails, arguments: {'course': course});
  }

  void clearFilters() {
    AppLogger.info('CoursesController.clearFilters(): reset filters');
    searchText.value = '';
    selectedCategory.value = 'All';
    selectedDifficulty.value = 'All';
    sortBy.value = 'Name';
    HapticUtils.mediumImpact();
  }

  String getCourseDescription(String language, String level, String intensity) {
    return 'This $level level path will guide you through $language at a $intensity pace. '
        'You will cover syntax, data structures, algorithms, and real-world projects.';
  }
}

import 'package:get/get.dart';
import '../../../data/models/course_model.dart';
import '../../../data/repositories/course_repository.dart';
import '../../../data/services/mock_api_service.dart';
import '../../../routes/app_pages.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CoursesController extends GetxController {
  late final CourseRepository _courseRepository;

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
    {'name': 'Python', 'icon': '🐍'},
    {'name': 'JavaScript', 'icon': '📜'},
    {'name': 'C++', 'icon': '⚙️'},
    {'name': 'Java', 'icon': '☕'},
    {'name': 'TypeScript', 'icon': '📘'},
    {'name': 'Go', 'icon': '🐹'},
  ];

  final creationDifficulties = ['Beginner', 'Intermediate', 'Advanced'];
  final creationSelectedDifficulty = 'Beginner'.obs;

  final creationIntensities = ['Casual', 'Regular', 'Intense'];
  final creationSelectedIntensity = 'Regular'.obs;

  void createLearningPath() async {
    isCreating.value = true;
    try {
      await Future.delayed(const Duration(seconds: 1)); // Mock API delay

      final service = Get.find<MockApiService>();
      service.createCourse(
        language: selectedLanguage.value,
        level: creationSelectedDifficulty.value,
        intensity: creationSelectedIntensity.value,
      );

      // Refresh courses list
      fetchCourses();

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
      AppLogger.error('Error creating learning path: $e');
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
    // In a real app, inject this properly
    _courseRepository = CourseRepositoryImpl(Get.find<MockApiService>());
    fetchCourses();
  }

  void fetchCourses() async {
    isLoading.value = true;
    try {
      final allCourses = _courseRepository.getAllCourses();
      courses.assignAll(allCourses);

      // Extract unique categories
      final distinctCategories = allCourses
          .map((c) => c.category)
          .toSet()
          .toList();
      categories.assignAll(['All', ...distinctCategories]);
    } catch (e) {
      AppLogger.error('Error fetching courses', e);
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
    isGridView.value = !isGridView.value;
    HapticUtils.selectionClick();
  }

  void openCourse(Course course) {
    HapticUtils.lightImpact();
    Get.toNamed(Routes.courseDetails, arguments: {'course': course});
  }

  void clearFilters() {
    searchText.value = '';
    selectedCategory.value = 'All';
    selectedDifficulty.value = 'All';
    sortBy.value = 'Name';
    HapticUtils.mediumImpact();
  }
}

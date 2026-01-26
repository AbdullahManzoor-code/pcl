import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/course_model.dart';
import '../../../data/repositories/course_repository.dart';
import '../../../data/services/mock_api_service.dart';

class MyCoursesController extends GetxController {
  late final CourseRepository _courseRepository;

  final enrolledCourses = <Course>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _courseRepository = Get.find<CourseRepository>();
    fetchEnrolledCourses();

    // Listen to global course changes for instant sync
    final service = Get.find<MockApiService>();
    ever(service.courses, (_) => fetchEnrolledCourses());
  }

  void fetchEnrolledCourses() async {
    isLoading.value = true;
    try {
      final courses = _courseRepository.getEnrolledCourses();
      enrolledCourses.assignAll(courses);
    } catch (e) {
      print('Error fetching enrolled courses: $e');
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
    {'name': 'Python', 'icon': '🐍'},
    {'name': 'JavaScript', 'icon': '📜'},
    {'name': 'C++', 'icon': '⚙️'},
    {'name': 'Java', 'icon': '☕'},
    {'name': 'TypeScript', 'icon': '📘'},
    {'name': 'Go', 'icon': '🐹'},
  ];

  final creationDifficulties = ['Easy', 'Medium', 'Hard'];
  final creationSelectedDifficulty = 'Medium'.obs;

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
        level: creationSelectedDifficulty.value,
        progress: 0.0,
        totalTopics: 10,
        topicsCompleted: 0,
        accuracy: 0,
        lastActivity: 'Just now',
        isEnrolled: true,
        image:
            'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/${selectedLanguage.value.toLowerCase()}/${selectedLanguage.value.toLowerCase()}-original.svg',
        description:
            'Master ${selectedLanguage.value} programming from basic to advanced concepts.',
        category: selectedLanguage.value,
        topics: [],
      );

      // Add to repository/service
      service.courses.add(newCourse.toJson());

      // Refresh courses list
      fetchEnrolledCourses();

      Get.snackbar(
        'Success',
        'Started new learning path: ${selectedLanguage.value}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF22C55E).withOpacity(0.1),
        colorText: const Color(0xFF22C55E),
        icon: const Icon(Icons.check_circle_outline, color: Color(0xFF22C55E)),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create learning path. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444).withOpacity(0.1),
        colorText: const Color(0xFFEF4444),
        icon: const Icon(Icons.error_outline, color: Color(0xFFEF4444)),
      );
      print('Error creating learning path: $e');
    } finally {
      isCreating.value = false;
    }
  }
}

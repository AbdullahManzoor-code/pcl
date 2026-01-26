import 'package:get/get.dart';
import 'package:pcl/app/core/theme/app_theme.dart';
import 'package:pcl/app/data/models/user_model.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/analytics_model.dart';
import '../../../data/repositories/course_repository.dart';
import '../../../data/services/mock_api_service.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../main/controllers/main_controller.dart';
import '../../../routes/app_pages.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class DashboardController extends GetxController {
  late final CourseRepository _courseRepository;

  final stats = <String, dynamic>{}.obs;
  final enrolledCourses = <Course>[].obs;
  final completedCourses = <Course>[].obs;
  final recommendedCourses = <Course>[].obs;
  final isLoading = true.obs;
  final aiEvaluation = <String, dynamic>{}.obs;
  final Rxn<RecommendedTopic> recommendedTopic = Rxn<RecommendedTopic>();
  final Rx<User> user = User().obs;
  final heatmapData = <String, int>{}.obs;

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
    _courseRepository = Get.find<CourseRepository>();
    fetchData();

    // Listen to global course changes for instant sync
    final service = Get.find<MockApiService>();
    ever(service.courses, (_) => fetchData());
  }

  void fetchData() async {
    try {
      final service = Get.find<MockApiService>();

      // Get user data from API service
      final userData = service.getUser();
      user.value = User.fromJson(userData);

      stats.assignAll(service.getUserStats());

      enrolledCourses.value = _courseRepository.getEnrolledCourses();
      completedCourses.value = _courseRepository.getCompletedCourses();
      recommendedCourses.value = _courseRepository.getRecommendedCourses();

      if (service.lastEvaluation.isNotEmpty) {
        aiEvaluation.assignAll(service.lastEvaluation);
      }

      final recommendationData = service.getAIRecommendation('python');
      recommendedTopic.value = RecommendedTopic.fromJson(recommendationData);

      heatmapData.assignAll(service.getHeatmapData());
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

      // Navigate to quiz directly
      Get.toNamed(
        Routes.quiz,
        arguments: {
          'conceptId': rec.conceptId,
          'conceptName': rec.conceptName,
          'difficulty': 0.7, // Set slightly higher for retake
          'numQuestions': 10,
          'mode': 'exam', // Encourage testing
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
    // ALWAYS use the Map format for consistency across the app
    Get.toNamed(Routes.courseDetails, arguments: {'course': course});
  }

  void continueLearning(Course course) {
    openCourse(course);
  }

  void goToMyCourses() => Get.toNamed(Routes.myCourses);
  void goToAllCourses() => Get.toNamed(Routes.courses);
  void goToNotifications() => Get.toNamed(Routes.notifications);
  void goToProfile() => Get.toNamed(Routes.profile);
  void goToPractice() => Get.toNamed(Routes.practice);
  void goToAnalytics() => Get.toNamed(Routes.analytics);

  void goToAnalyticsTab() {
    HapticUtils.mediumImpact();
    Get.find<MainController>().changePage(
      4,
    ); // Consistent cross-controller access
  }

  Future<void> changeProfilePicture() async {
    try {
      final ImagePicker picker = ImagePicker();

      // Show option dialog
      final source = await Get.dialog<ImageSource>(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose Profile Picture',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    color: AppColors.primary,
                  ),
                  title: const Text('Take Photo'),
                  onTap: () => Get.back(result: ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: AppColors.primary,
                  ),
                  title: const Text('Choose from Gallery'),
                  onTap: () => Get.back(result: ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Picture'),
                  onTap: () => Get.back(result: null),
                ),
              ],
            ),
          ),
        ),
      );

      if (source == null && source != false) {
        // User chose to remove picture
        final service = Get.find<MockApiService>();
        service.updateProfilePic(null);
        fetchData();
        Get.snackbar(
          'Success',
          'Profile picture removed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success.withOpacity(0.1),
          colorText: AppColors.success,
        );
        return;
      }

      if (source != null) {
        // Request permissions based on source
        Permission permission = source == ImageSource.camera 
            ? Permission.camera 
            : Permission.photos;
        
        PermissionStatus status = await permission.request();
        
        if (!status.isGranted) {
          Get.snackbar(
            'Permission Denied',
            'Please grant ${source == ImageSource.camera ? "camera" : "storage"} permission to continue',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error.withOpacity(0.1),
            colorText: AppColors.error,
          );
          return;
        }

        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 85,
        );

        if (image != null) {
          final service = Get.find<MockApiService>();
          service.updateProfilePic(image.path);
          fetchData();

          HapticUtils.lightImpact();
          Get.snackbar(
            'Success',
            'Profile picture updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success.withOpacity(0.1),
            colorText: AppColors.success,
          );
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar(
        'Error',
        'Failed to update profile picture',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
    }
  }
}

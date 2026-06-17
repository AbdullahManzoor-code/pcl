import 'package:get/get.dart';
import 'package:pcl/app/core/theme/app_theme.dart';
import 'package:pcl/app/data/models/user_model.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/analytics_model.dart';
import '../../../data/services/course_service.dart';
import '../../../data/services/course_api_adapter.dart';
import '../../../data/services/dashboard_service.dart';
import '../../../data/services/mock_api_service.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../main/controllers/main_controller.dart';
import '../../../routes/app_pages.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/services/exam_service.dart';

class DashboardController extends GetxController {
  late final CourseService _courseService;
  late final DashboardService _dashboardService;

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
    {'name': 'Python', 'id': 'python_3', 'icon': '🐍'},
    {'name': 'JavaScript', 'id': 'javascript_es6', 'icon': '📜'},
    {'name': 'C++', 'id': 'cpp_20', 'icon': '⚙️'},
    {'name': 'Java', 'id': 'java_17', 'icon': '☕'},
    {'name': 'TypeScript', 'id': 'typescript_5', 'icon': '📘'},
    {'name': 'Go', 'id': 'go_1_21', 'icon': '🐹'},
  ];

  final difficulties = ['Easy', 'Medium', 'Hard'];

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('DashboardController.onInit(): loading dashboard data');
    _courseService = Get.find<CourseService>();
    _dashboardService = Get.put(DashboardService()); // Instantiate locally
    fetchData();
  }

  void fetchData() async {
    AppLogger.info('DashboardController.fetchData(): start');
    isLoading.value = true;
    try {
      final mockService = Get.find<MockApiService>();
      final examService = Get.find<ExamService>();

      // Get user data from mock API service (until User Service is built)
      final userData = mockService.getUser();
      user.value = User.fromJson(userData);
      AppLogger.debug(
        'DashboardController.fetchData(): user loaded id=${user.value.id}',
      );

      // Calculate real stats from exam history
      try {
        final historyRes = await examService.getExamHistory(limit: 100);
        int totalExams = historyRes.sessions.length;
        double sumAccuracy = 0;
        for (var s in historyRes.sessions) {
          sumAccuracy += s.overallScore;
        }
        int avgAccuracy = totalExams > 0
            ? ((sumAccuracy / totalExams) * 100).toInt()
            : 0;

        stats.assignAll({
          'exams_completed': totalExams,
          'accuracy': '$avgAccuracy%',
          'current_streak': 0, // Fallback streak
        });
        AppLogger.info(
          'DashboardController.fetchData(): exam history loaded sessions=$totalExams',
        );
      } catch (_) {
        AppLogger.warning(
          'DashboardController.fetchData(): exam history unavailable, using mock stats',
        );
        stats.assignAll(mockService.getUserStats());
      }

      // Fetch enrolled courses via Real API
      final portfolio = await _courseService.getUserLanguages();
      final courses = portfolio.languages
          .map((stat) => CourseApiAdapter.mapLanguageStatsToCourse(stat))
          .toList();
      enrolledCourses.assignAll(courses);
      AppLogger.info(
        'DashboardController.fetchData(): enrolled courses=${courses.length}',
      );

      // Set dummy completed/recommended until endpoints exist
      completedCourses.assignAll(courses.where((c) => c.isCompleted).toList());
      recommendedCourses.assignAll(
        [],
      ); // Can be fetched from getCurriculum later

      // Fetch dashboard summary for the first enrolled language (or python_3 as fallback)
      final activeLangId = portfolio.languages.isNotEmpty
          ? portfolio.languages.first.languageId
          : 'python_3';

      try {
        final summary = await _dashboardService.getDashboardSummary(
          activeLangId,
        );
        recommendedTopic.value = summary.recommendation;
        AppLogger.info(
          'DashboardController.fetchData(): dashboard summary loaded languageId=$activeLangId',
        );

        // Mock heatmap data for UI consistency until backend supports session heatmap API
        heatmapData.assignAll(mockService.getHeatmapData());
      } catch (e, stackTrace) {
        AppLogger.warning(
          'DashboardController.fetchData(): dashboard summary fallback for languageId=$activeLangId',
          e,
          stackTrace,
        );
        // Fallback to mock for new users
        final recommendationData = mockService.getAIRecommendation('python');
        recommendedTopic.value = RecommendedTopic.fromJson(recommendationData);
        heatmapData.assignAll(mockService.getHeatmapData());
      }

      if (mockService.lastEvaluation.isNotEmpty) {
        aiEvaluation.assignAll(mockService.lastEvaluation);
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'DashboardController.fetchData(): failed to load dashboard data',
        e,
        stackTrace,
      );
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
    AppLogger.info('DashboardController.navigateToRecommendation(): tapped');
    try {
      final rec = recommendedTopic.value;
      if (rec == null) {
        AppLogger.warning(
          'DashboardController.navigateToRecommendation(): no recommendation available',
        );
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
          'difficulty': rec.targetDifficulty,
          'numQuestions': 10,
          'mode': 'exam', // Encourage testing
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'DashboardController.navigateToRecommendation(): navigation failed',
        e,
        stackTrace,
      );
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
    AppLogger.info('DashboardController.openCourse(): courseId=${course.id}');
    // ALWAYS use the Map format for consistency across the app
    Get.toNamed(Routes.courseDetails, arguments: {'course': course});
  }

  void continueLearning(Course course) {
    AppLogger.info(
      'DashboardController.continueLearning(): courseId=${course.id}',
    );
    openCourse(course);
  }

  void goToMyCourses() {
    AppLogger.info('DashboardController.goToMyCourses(): tapped');
    Get.toNamed(Routes.myCourses);
  }

  void goToAllCourses() {
    AppLogger.info('DashboardController.goToAllCourses(): tapped');
    Get.toNamed(Routes.courses);
  }

  void goToNotifications() {
    AppLogger.info('DashboardController.goToNotifications(): tapped');
    Get.toNamed(Routes.notifications);
  }

  void goToProfile() {
    AppLogger.info('DashboardController.goToProfile(): tapped');
    Get.toNamed(Routes.profile);
  }

  void goToPractice() {
    AppLogger.info('DashboardController.goToPractice(): tapped');
    Get.toNamed(Routes.practice);
  }

  void goToAnalytics() {
    AppLogger.info('DashboardController.goToAnalytics(): tapped');
    Get.toNamed(Routes.analytics);
  }

  void goToAnalyticsTab() {
    AppLogger.info('DashboardController.goToAnalyticsTab(): switching tab');
    HapticUtils.mediumImpact();
    Get.find<MainController>().changePage(
      4,
    ); // Consistent cross-controller access
  }

  Future<void> changeProfilePicture() async {
    AppLogger.info('DashboardController.changeProfilePicture(): tapped');
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
        AppLogger.info(
          'DashboardController.changeProfilePicture(): removing picture',
        );
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
          AppLogger.warning(
            'DashboardController.changeProfilePicture(): permission denied source=$source',
          );
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
          AppLogger.info(
            'DashboardController.changeProfilePicture(): image selected path=${image.path}',
          );
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
    } catch (e, stackTrace) {
      AppLogger.error(
        'DashboardController.changeProfilePicture(): failed',
        e,
        stackTrace,
      );
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

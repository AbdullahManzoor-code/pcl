import 'package:get/get.dart';
import 'package:pcl/app/core/theme/app_theme.dart';
import 'package:pcl/app/data/models/user_model.dart';
import 'package:pcl/app/data/services/mock_api_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/analytics_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/course_service.dart';
import '../../../data/services/course_api_adapter.dart';
import '../../../data/services/dashboard_service.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../main/controllers/main_controller.dart';
import '../../../routes/app_pages.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/services/exam_service.dart';
import '../../../data/models/dashboard_api_models.dart';
import '../../../data/models/dashboard_models.dart' hide RecentSession;
import 'package:intl/intl.dart';

class DashboardController extends GetxController {
  late final CourseService _courseService;
  late final DashboardService _dashboardService;
  late final AuthService _authService;

  final stats = <String, dynamic>{}.obs;
  final enrolledCourses = <Course>[].obs;
  final completedCourses = <Course>[].obs;
  final recommendedCourses = <Course>[].obs;
  final isLoading = true.obs;
  final aiEvaluation = <String, dynamic>{}.obs;
  final Rxn<RecommendedTopic> recommendedTopic = Rxn<RecommendedTopic>();
  final Rx<User> user = User().obs;
  final heatmapDays = <String, HeatmapDay>{}.obs;
  final heatmapFilter = 'month'.obs; // 'week' | 'month' | '6m' | 'year'
  final isHeatmapLoading = false.obs;

  // Phase 1: New state for mastery and progress
  final masteryScores = <TopicMastery>[].obs;
  final languageProgress = Rxn<StudentProgressResponse>();
  final activeLangId = ''.obs;

  // New state for advanced dashboard features
  final transferBoosts = <TransferBoost>[].obs;
  final synergyBonuses = <SynergyBonus>[].obs;

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
    _dashboardService = Get.find<DashboardService>();
    _authService = Get.find<AuthService>();
    fetchData();
  }

  void fetchData() async {
    AppLogger.info('DashboardController.fetchData(): start');
    isLoading.value = true;
    try {
      final examService = Get.find<ExamService>();

      // Get user data from real API
      final userData = await _authService.getMe();
      user.value = userData;
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
        stats.assignAll({}); // Fallback to empty stats
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
      final activeLangIdValue = portfolio.languages.isNotEmpty
          ? portfolio.languages.first.languageId
          : 'python_3';

      activeLangId.value = activeLangIdValue;

      try {
        final summary = await _dashboardService.getDashboardSummary(
          activeLangIdValue,
        );
        recommendedTopic.value = summary.recommendation;
        // Heatmap data is fetched separately via getExamHistory (365 days)
        AppLogger.info(
          'DashboardController.fetchData(): dashboard summary loaded languageId=$activeLangIdValue',
        );

        // // Phase 1: Fetch mastery scores and language progress
        // try {
        //   final mastery = await _dashboardService.getMasteryScores(
        //     activeLangIdValue,
        //   );
        //   masteryScores.assignAll(mastery);
        //   AppLogger.info(
        //     'DashboardController.fetchData(): mastery scores loaded count=${mastery.length}',
        //   );
        // } catch (e) {
        //   AppLogger.warning(
        //     'DashboardController.fetchData(): mastery scores unavailable',
        //     e,
        //   );
        // }

        try {
          final progress = await _dashboardService.getLanguageProgress(
            activeLangIdValue,
          );
          languageProgress.value = progress;
          AppLogger.info(
            'DashboardController.fetchData(): language progress loaded topics=${progress.topics.length}',
          );
        } catch (e) {
          AppLogger.warning(
            'DashboardController.fetchData(): language progress unavailable',
            e,
          );
        }

        // Fetch non-critical advanced features
        // try {
        //   final boosts = await _dashboardService.getActiveTransferBoosts(
        //     activeLangIdValue,
        //   );
        //   transferBoosts.assignAll(boosts);
        //   AppLogger.info(
        //     'DashboardController.fetchData(): transfer boosts loaded count=${boosts.length}',
        //   );
        // } catch (e) {
        //   AppLogger.warning(
        //     'DashboardController.fetchData(): transfer boosts unavailable',
        //     e,
        //   );
        // }

        try {
          final bonuses = await _dashboardService.getRecentSynergyBonuses(
            activeLangIdValue,
          );
          synergyBonuses.assignAll(bonuses);
          AppLogger.info(
            'DashboardController.fetchData(): synergy bonuses loaded count=${bonuses.length}',
          );
        } catch (e) {
          AppLogger.warning(
            'DashboardController.fetchData(): synergy bonuses unavailable',
            e,
          );
        }
      } catch (e, stackTrace) {
        AppLogger.warning(
          'DashboardController.fetchData(): dashboard summary fallback for languageId=$activeLangIdValue',
          e,
          stackTrace,
        );
        // Fallback for new users
        recommendedTopic.value = null;
      }

      // Fetch full 365-day history for heatmap (non-blocking, after main data)
      _fetchHeatmapData(activeLangIdValue);
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

  Future<void> _fetchHeatmapData(String langId) async {
    AppLogger.info('DashboardController._fetchHeatmapData(): fetching 365-day history');
    isHeatmapLoading.value = true;
    try {
      final examService = Get.find<ExamService>();
      final history = await examService.getExamHistory(
        languageId: langId.isNotEmpty ? langId : null,
        limit: 365,
      );
      final Map<String, HeatmapDay> result = {};
      final fmt = DateFormat('yyyy-MM-dd');
      for (final s in history.sessions) {
        final key = fmt.format(s.completedAt);
        final existing = result[key];
        if (existing == null) {
          result[key] = HeatmapDay(sessionCount: 1, avgScore: s.accuracy);
        } else {
          final newCount = existing.sessionCount + 1;
          final newAvg =
              ((existing.avgScore * existing.sessionCount) + s.accuracy) /
              newCount;
          result[key] = HeatmapDay(sessionCount: newCount, avgScore: newAvg);
        }
      }
      heatmapDays.assignAll(result);
      AppLogger.info(
        'DashboardController._fetchHeatmapData(): loaded ${result.length} active days',
      );
    } catch (e, stackTrace) {
      AppLogger.warning(
        'DashboardController._fetchHeatmapData(): failed',
        e,
        stackTrace,
      );
    } finally {
      isHeatmapLoading.value = false;
    }
  }

  void navigateToRecommendation() async {
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

      // We need to find the mappingId from the curriculum
      final curriculums = await _courseService.getCurriculum();
      final roadmap = curriculums.firstWhereOrNull((c) => c.languageId == activeLangId.value)?.roadmap ?? [];
      final currTopic = roadmap.firstWhereOrNull((ct) => ct.majorTopicId == rec.conceptId);
      final mappingId = currTopic?.mappingId ?? 'UNIV_VAR';

      // Navigate to quiz directly
      Get.toNamed(
        Routes.quiz,
        arguments: {
          'sessionId': '',
          'startTime': null,
          'languageId': activeLangId.value,
          'mappingId': mappingId,
          'majorTopicId': rec.conceptId,
          'numQuestions': 10,
          'mode': 'exam', // Encourage testing
          'difficulty': rec.targetDifficulty,
          'isDiagnostic': false,
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

      if (source == null) {
        // User chose to remove picture or cancelled dialog
        AppLogger.info(
          'DashboardController.changeProfilePicture(): removing picture',
        );
        // TODO: Add API call to remove profile picture
        fetchData();
        Get.snackbar(
          'Success',
          'Profile picture removed (UI only)',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success.withOpacity(0.1),
          colorText: AppColors.success,
        );
        return;
      }

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
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
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
        // TODO: Add API call to upload profile picture
        fetchData();

        HapticUtils.lightImpact();
        Get.snackbar(
          'Success',
          'Profile picture updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success.withValues(alpha: 0.1),
          colorText: AppColors.success,
        );
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

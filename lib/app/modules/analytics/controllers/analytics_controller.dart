import 'package:get/get.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/models/dashboard_api_models.dart';
import '../../../data/models/analytics_model.dart';
import '../../../data/services/dashboard_service.dart';

class AnalyticsController extends GetxController {
  late final DashboardService _dashboardService;

  final isLoading = true.obs;
  final selectedLanguage = 'python_3'.obs; // Default language

  final masteryData = <TopicMastery>[].obs;
  final recentActivity = <RecentSession>[].obs; // Changed from PracticeSession

  // Additional observable properties for UI bindings
  final conceptsPracticed = 0.obs;
  final avgMastery = 0.0.obs;
  final totalSessions = 0.obs;
  final avgScore = 0.0.obs;
  final activeTransferBoostsCount = 0.obs;
  final recentSynergyBonusesCount = 0.obs;
  // Alias lists for view convenience
  final masteryList = <TopicMastery>[].obs;
  final sessionList = <RecentSession>[].obs;
  final decayAlerts = <DecayAlert>[].obs;
  final activityByDay = <DateTime, int>{}.obs;

  final languages = [
    {'name': 'Python', 'id': 'python_3', 'icon': '🐍'},
    {'name': 'JavaScript', 'id': 'javascript_es6', 'icon': '📜'},
    {'name': 'C++', 'id': 'cpp_20', 'icon': '⚙️'},
    {'name': 'Java', 'id': 'java_17', 'icon': '☕'},
    {'name': 'TypeScript', 'id': 'typescript_5', 'icon': '📘'},
    {'name': 'Go', 'id': 'go_1_21', 'icon': '🐹'},
  ];

  @override
  void onInit() {
    super.onInit();
    _dashboardService = Get.find<DashboardService>();
    fetchAnalyticsData();
  }

  void fetchAnalyticsData() async {
    AppLogger.info('AnalyticsController.fetchAnalyticsData(): start');
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _dashboardService.getDashboardSummary(selectedLanguage.value),
        // _dashboardService.getActiveTransferBoosts(selectedLanguage.value),
        // _dashboardService.getRecentSynergyBonuses(
        //   selectedLanguage.value,
        //   days: 7,
        // ),
      ]);

      final summary = results[0] as DashboardSummary;
      // final transferBoosts = results[1] as List<TransferBoost>;
      // final synergyBonuses = results[2] as List<SynergyBonus>;

      masteryData.assignAll(summary.masteryData);
      recentActivity.assignAll(summary.recentSessions);
      decayAlerts.assignAll(summary.decayAlerts);
      _processActivityData(summary.recentSessions);

      // // Store stats
      // activeTransferBoostsCount.value = transferBoosts.length;
      // recentSynergyBonusesCount.value = synergyBonuses.length;

      // Update additional observables
      conceptsPracticed.value = summary.masteryData.length;
      avgMastery.value = summary.masteryData.isNotEmpty
          ? summary.masteryData.map((e) => e.mastery).reduce((a, b) => a + b) /
                summary.masteryData.length
          : 0.0;
      totalSessions.value = summary.recentSessions.length;
      avgScore.value = summary.recentSessions.isNotEmpty
          ? summary.recentSessions.map((e) => e.score).reduce((a, b) => a + b) /
                summary.recentSessions.length
          : 0.0;

      // Populate alias lists
      masteryList.assignAll(summary.masteryData);
      sessionList.assignAll(summary.recentSessions);
    } catch (e, stackTrace) {
      AppLogger.error(
        'AnalyticsController.fetchAnalyticsData(): failed',
        e,
        stackTrace,
      );
      Get.snackbar('Error', 'Failed to load analytics data.');
    } finally {
      isLoading.value = false;
    }
  }

  void _processActivityData(List<RecentSession> sessions) {
    final Map<DateTime, int> data = {};
    for (var session in sessions) {
      final date = DateTime.parse(session.timestamp).toLocal();
      final day = DateTime(date.year, date.month, date.day);
      data[day] = (data[day] ?? 0) + 1;
    }
    activityByDay.assignAll(data);
  }

  void changeLanguage(String languageId) {
    selectedLanguage.value = languageId;
    fetchAnalyticsData(); // Reload data for new language
  }

  // Public method used by view to trigger refresh
  void fetchAnalytics() => fetchAnalyticsData();

  // Trigger practice again action
  void practiceAgain(
    String conceptId,
    String? subTopic, {
    double? difficulty,
    int? questionCount,
  }) {
    // Navigate to the practice page with pre-filled concept and optional subtopic.
    // Construct query parameters.
    final query = {
      'conceptId': conceptId,
      if (subTopic != null && subTopic.isNotEmpty) 'subTopic': subTopic,
      // Force practice mode.
      'mode': 'practice',
      if (difficulty != null) 'difficulty': difficulty,
      if (questionCount != null) 'questionCount': questionCount,
    };
    // Log navigation.
    AppLogger.info(
      'AnalyticsController.practiceAgain(): navigating to /practice with $query',
    );
    // Use GetX navigation to push the route.
    // Assuming a named route '/practice' exists in the Flutter app.
    Get.toNamed('/practice', arguments: query);
  }
}

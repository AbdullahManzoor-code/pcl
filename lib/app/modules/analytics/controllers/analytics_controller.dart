import 'package:get/get.dart';
import '../../../data/services/mock_api_service.dart';
import '../../../data/models/analytics_model.dart';

class AnalyticsController extends GetxController {
  final masteryList = <TopicMastery>[].obs;
  final sessionList = <PracticeSession>[].obs;
  final isLoading = true.obs;

  // Calculated Summary Stats
  final conceptsPracticed = 0.obs;
  final avgMastery = 0.obs;
  final totalSessions = 0.obs;
  final avgScore = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAnalytics();
  }

  void fetchAnalytics() async {
    isLoading.value = true;
    try {
      final service = Get.find<MockApiService>();

      // Fetch Mastery Data
      final masteryData = service.getTopicMastery('python');
      masteryList.assignAll(
        masteryData.map((m) => TopicMastery.fromJson(m)).toList(),
      );

      // Fetch Session Data
      final sessionData = service.getRecentSessions('python');
      sessionList.assignAll(
        sessionData.map((s) => PracticeSession.fromJson(s)).toList(),
      );

      _calculateStats();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load analytics: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateStats() {
    final practiced = masteryList.where((m) => m.mastery > 0).toList();
    conceptsPracticed.value = practiced.length;

    if (practiced.isNotEmpty) {
      final totalDecayedMastery = practiced.fold(
        0.0,
        (sum, m) => sum + m.decayedMastery,
      );
      avgMastery.value = ((totalDecayedMastery / practiced.length) * 100)
          .round();
    } else {
      avgMastery.value = 0;
    }

    totalSessions.value = sessionList.length;

    if (sessionList.isNotEmpty) {
      final totalScore = sessionList.fold(0.0, (sum, s) => sum + s.score);
      avgScore.value = ((totalScore / sessionList.length) * 100).round();
    } else {
      avgScore.value = 0;
    }
  }

  void practiceAgain(String conceptId, String subTopic) {
    // Navigate back to practice or deep link to specific topic
    Get.snackbar(
      'Practice Again',
      'Starting session for $subTopic...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

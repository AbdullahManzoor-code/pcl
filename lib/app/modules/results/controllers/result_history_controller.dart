import 'package:get/get.dart';
import '../../../data/models/exam_api_models.dart';
import '../../../data/services/exam_service.dart';
import '../../../core/utils/app_logger.dart';

class ResultHistoryController extends GetxController {
  final ExamService _examService = Get.find<ExamService>();

  final history = <SessionHistoryItem>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('ResultHistoryController.onInit(): loading exam history');
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    isLoading.value = true;
    try {
      AppLogger.debug(
        'ResultHistoryController.fetchHistory(): requesting last 50 sessions',
      );
      final res = await _examService.getExamHistory(limit: 50);
      history.assignAll(res.sessions);
      AppLogger.info(
        'ResultHistoryController.fetchHistory(): loaded ${res.sessions.length} sessions',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'ResultHistoryController.fetchHistory(): failed to load exam history',
        e,
        stackTrace,
      );
      Get.snackbar('Error', 'Failed to load exam history');
    } finally {
      isLoading.value = false;
    }
  }
}

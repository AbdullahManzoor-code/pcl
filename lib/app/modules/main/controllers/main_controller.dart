import 'package:get/get.dart';
import '../../../core/utils/app_logger.dart';

class MainController extends GetxController {
  final currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('MainController.onInit(): shell initialized');
  }

  void changePage(int index) {
    if (index >= 0 && index < 4) {
      AppLogger.info('MainController.changePage(): index=$index');
      currentIndex.value = index;
    } else {
      AppLogger.warning(
        'MainController.changePage(): ignored invalid index=$index',
      );
    }
  }
}

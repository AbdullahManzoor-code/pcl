import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../core/utils/app_logger.dart';

class LandingController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    AppLogger.info('LandingController.onInit(): landing screen ready');
  }

  void navigateToLogin() {
    AppLogger.info('LandingController.navigateToLogin(): CTA tapped');
    Get.toNamed(Routes.auth);
  }

  void navigateToRegister() {
    AppLogger.info('LandingController.navigateToRegister(): CTA tapped');
    Get.toNamed(Routes.onboarding);
  }
}

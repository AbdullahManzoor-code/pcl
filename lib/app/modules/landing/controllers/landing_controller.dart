import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class LandingController extends GetxController {
  void navigateToLogin() {
    Get.toNamed(Routes.auth);
  }

  void navigateToRegister() {
    Get.toNamed(Routes.onboarding);
  }
}

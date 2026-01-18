import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class LandingController extends GetxController {
  void navigateToLogin() {
    Get.toNamed(Routes.auth);
  }

  void navigateToRegister() {
    Get.toNamed(Routes.auth); // Currently Auth points to Login, user can toggle
    // Ideally separate routes or arguments
    Get.toNamed(Routes.register);
  }
}

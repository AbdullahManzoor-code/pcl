import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _startAppFlow();
  }

  Future<void> _startAppFlow() async {
    await Future.delayed(
      const Duration(seconds: 3),
    ); // Show splash for 3 seconds

    final storage = GetStorage();
    final bool isLoggedIn = storage.read('isLoggedIn') ?? false;
    final bool isFirstLaunch = storage.read('isFirstLaunch') ?? true;

    if (isLoggedIn) {
      Get.offAllNamed(Routes.main);
    } else if (isFirstLaunch) {
      Get.offAllNamed(Routes.onboarding);
    } else {
      Get.offAllNamed(Routes.landing);
    }
  }
}

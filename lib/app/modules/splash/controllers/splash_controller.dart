import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_pages.dart';
import '../../../data/services/auth_service.dart';
import '../../../core/utils/app_logger.dart';

class SplashController extends GetxController {
  final _authService = Get.find<AuthService>();
  final _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('SplashController.onInit(): starting startup flow');
    _startAppFlow();
  }

  Future<void> _startAppFlow() async {
    AppLogger.info(
      'SplashController._startAppFlow(): evaluating startup state',
    );

    await Future.delayed(
      const Duration(seconds: 2),
    ); // Show splash for 2 seconds

    try {
      // Step 1: Try to restore session from storage
      if (_authService.isSessionValid()) {
        AppLogger.info(
          'SplashController._startAppFlow(): session found, attempting restore',
        );

        final sessionRestored = await _authService.restoreSession();
        if (sessionRestored && _authService.isAuthenticated()) {
          AppLogger.info(
            'SplashController._startAppFlow(): session restored, routing to main',
          );
          Get.offAllNamed(Routes.main);
          return;
        } else {
          AppLogger.warning(
            'SplashController._startAppFlow(): session restore failed, redirecting to login',
          );
          await _authService.logout();
        }
      }

      // Step 2: Check if first launch
      final bool isFirstLaunch = _storage.read('isFirstLaunch') ?? true;
      if (isFirstLaunch) {
        AppLogger.info(
          'SplashController._startAppFlow(): first launch, routing to onboarding',
        );
        Get.offAllNamed(Routes.onboarding);
      } else {
        AppLogger.info(
          'SplashController._startAppFlow(): not first launch, routing to landing',
        );
        Get.offAllNamed(Routes.auth);
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'SplashController._startAppFlow(): startup flow failed',
        e,
        stackTrace,
      );
      // Fallback to landing page
      final bool isFirstLaunch = _storage.read('isFirstLaunch') ?? true;
      Get.offAllNamed(isFirstLaunch ? Routes.onboarding : Routes.auth);
    }
  }
}

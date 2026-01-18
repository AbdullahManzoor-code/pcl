import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/mock_api_service.dart';
import '../../../data/services/notification_service.dart';
import '../../../data/services/theme_service.dart';

class ProfileController extends GetxController {
  late final AuthRepository _authRepository;
  final ThemeService _themeService = Get.find<ThemeService>();
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  final user = Rxn<User>();
  final isLoading = true.obs;

  // Profile Form Fields
  final nameValue = ''.obs;
  final usernameValue = ''.obs;
  final emailValue = ''.obs;

  // Notification Settings
  final emailNotifications = true.obs;
  final testReminders = true.obs;
  final weeklyProgress = false.obs;
  final achievementAlerts = true.obs;

  @override
  void onInit() {
    super.onInit();
    _authRepository = AuthRepositoryImpl(Get.find<MockApiService>());
    fetchProfile();

    // Sync with notification service
    emailNotifications.value = _notificationService.isEnabled.value;

    // Listen to changes and update service
    emailNotifications.listen((val) {
      _notificationService.toggleNotifications(val);
    });
  }

  void fetchProfile() async {
    isLoading.value = true;
    try {
      final mockUser = await _authRepository.login('mock', 'mock');
      user.value = mockUser;

      // Initialize form fields
      nameValue.value = mockUser?.name ?? '';
      usernameValue.value = 'mian_user';
      emailValue.value = mockUser?.email ?? '';
    } catch (e) {
      print('Error fetching profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile() async {
    if (user.value == null) return;

    if (nameValue.value.trim().isEmpty) {
      Get.snackbar('Validation', 'Name cannot be empty');
      return;
    }

    isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 1000)); // Mock delay

      final mockApi = Get.find<MockApiService>();
      mockApi.updateProfile(nameValue.value.trim());

      final currentUser = user.value!;
      user.value = currentUser.copyWith(name: nameValue.value.trim());

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile.');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleTheme() {
    _themeService.changeThemeMode(!_themeService.isDarkMode());
  }

  bool get isDarkMode => _themeService.isDarkMode();

  void logout() {
    Get.defaultDialog(
      title: 'Logout',
      middleText: 'Are you sure you want to logout?',
      textConfirm: 'Logout',
      textCancel: 'Cancel',
      confirmTextColor: Get.theme.canvasColor,
      onConfirm: () {
        Get.back();
        Get.offAllNamed('/auth'); // Route to auth/login
      },
    );
  }
}

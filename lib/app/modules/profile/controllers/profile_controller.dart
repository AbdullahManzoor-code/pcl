import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/views/login_view.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/mock_api_service.dart';
import '../../../data/services/notification_service.dart';
import '../../../data/services/theme_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/next_components.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pcl/app/services/validation_service.dart';

class ProfileController extends GetxController {
  final _validationService = Get.find<ValidationService>();
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

  // Password Change Fields
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();
  final isChangingPassword = false.obs;

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

    final nameError = _validationService.validateName(nameValue.value.trim());
    if (nameError != null) {
      Get.snackbar('Validation Error', nameError);
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
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: Get.isDarkMode
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 24.h),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Text(
              'Logout',
              style: GoogleFonts.outfit(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Are you sure you want to logout? You will need to login again to access your account.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey),
            ),
            SizedBox(height: 32.h),
            Row(
              children: [
                Expanded(
                  child: NextButton(
                    text: 'Cancel',
                    outline: true,
                    onPressed: () => Get.back(),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: NextButton(
                    text: 'Logout',
                    color: AppColors.error,
                    onPressed: () {
                      Get.back();
                      Get.offAll(() => const LoginView());
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> changePassword() async {
    final newPassError = _validationService.validatePassword(
      newPasswordController.text,
    );
    final confirmError = _validationService.validateConfirmPassword(
      newPasswordController.text,
      confirmNewPasswordController.text,
    );

    if (newPassError != null || confirmError != null) {
      Get.snackbar('Validation Error', newPassError ?? confirmError!);
      return;
    }

    isChangingPassword.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 1500)); // Mock delay
      Get.back(); // Close dialog/view
      Get.snackbar('Success', 'Password changed successfully');

      // Clear fields
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmNewPasswordController.clear();
    } catch (e) {
      Get.snackbar('Error', 'Failed to change password');
    } finally {
      isChangingPassword.value = false;
    }
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.onClose();
  }
}

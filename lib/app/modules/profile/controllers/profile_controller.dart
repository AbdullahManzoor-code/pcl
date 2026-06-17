import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pcl/app/routes/app_pages.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/mock_api_service.dart';
import '../../../data/services/notification_service.dart';
import '../../../data/services/theme_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/next_components.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pcl/app/services/validation_service.dart';
import '../../../data/models/achievement_model.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/haptic_utils.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileController extends GetxController {
  final _validationService = Get.find<ValidationService>();
  final ThemeService _themeService = Get.find<ThemeService>();
  final NotificationService _notificationService =
      Get.find<NotificationService>();
  final AuthService _authService = Get.find<AuthService>();

  final user = Rxn<User>();
  final isLoading = true.obs;

  // Profile Form Fields
  final nameValue = ''.obs;
  final usernameValue = ''.obs;
  final emailValue = ''.obs;
  final phoneValue = ''.obs;
  final altEmailValue = ''.obs;
  final profileImageUrl = Rxn<String>();
  final achievements = <Achievement>[].obs;

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
    AppLogger.info('ProfileController.onInit(): loading profile');
    fetchProfile();

    // Sync with notification service
    emailNotifications.value = _notificationService.isEnabled.value;

    // Listen to changes and update service
    emailNotifications.listen((val) {
      AppLogger.info(
        'ProfileController.onInit(): notification preference changed value=$val',
      );
      _notificationService.toggleNotifications(val);
    });
  }

  void fetchProfile() async {
    AppLogger.info('ProfileController.fetchProfile(): start');
    isLoading.value = true;
    try {
      // Fetch user from real API
      final realUser = await _authService.getMe();
      user.value = realUser;
      AppLogger.debug(
        'ProfileController.fetchProfile(): user loaded email=${realUser.email}${user.value?.name != null ? ' name=${user.value!.name}' : ''}',
      );

      final storage = GetStorage();
      final storedName = storage.read('userName') ?? 'Mian'; // Fallback
      final storedPhone = storage.read('userPhone') ?? '+1 (555) 000-0000';

      // Initialize form fields
      nameValue.value = storedName;
      usernameValue.value = realUser.email?.split('@').first ?? 'user';
      emailValue.value = realUser.email ?? '';
      phoneValue.value = storedPhone;
      altEmailValue.value = 'secondary@example.com';
      profileImageUrl.value = storage.read('profilePicUrl') ?? null;

      // Mock Achievements until backend supports them
      final mockService = Get.find<MockApiService>();
      final achData = mockService.getAllAchievements();
      achievements.assignAll(
        achData
            .map(
              (e) => Achievement.fromJson(
                e,
                icon: _getIconForCategory(e['category']),
                color: _getColorForCategory(e['category']),
              ),
            )
            .toList(),
      );
      AppLogger.info(
        'ProfileController.fetchProfile(): achievements=${achievements.length}',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'ProfileController.fetchProfile(): failed',
        e,
        stackTrace,
      );
      Get.snackbar('Error', 'Failed to fetch user profile.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeProfilePicture() async {
    AppLogger.info('ProfileController.changeProfilePicture(): tapped');
    try {
      final ImagePicker picker = ImagePicker();

      // Show option dialog
      final source = await Get.dialog<ImageSource>(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose Profile Picture',
                  style: GoogleFonts.outfit(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 24.h),
                ListTile(
                  leading: Icon(Icons.camera_alt, color: AppColors.primary),
                  title: Text('Take Photo', style: GoogleFonts.inter()),
                  onTap: () => Get.back(result: ImageSource.camera),
                ),
                ListTile(
                  leading: Icon(Icons.photo_library, color: AppColors.primary),
                  title: Text(
                    'Choose from Gallery',
                    style: GoogleFonts.inter(),
                  ),
                  onTap: () => Get.back(result: ImageSource.gallery),
                ),
                if (profileImageUrl.value != null)
                  ListTile(
                    leading: Icon(Icons.delete, color: AppColors.error),
                    title: Text(
                      'Remove Picture',
                      style: GoogleFonts.inter(color: AppColors.error),
                    ),
                    onTap: () => Get.back(result: null),
                  ),
              ],
            ),
          ),
        ),
      );

      if (source == null && source != false) {
        // User chose to remove picture
        AppLogger.info(
          'ProfileController.changeProfilePicture(): removing profile picture',
        );
        final service = Get.find<MockApiService>();
        service.updateProfilePic(null);
        profileImageUrl.value = null;
        fetchProfile();

        HapticUtils.lightImpact();
        Get.snackbar(
          'Success',
          'Profile picture removed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success.withOpacity(0.1),
          colorText: AppColors.success,
        );
        return;
      }

      if (source != null) {
        // Request permissions based on source
        Permission permission = source == ImageSource.camera
            ? Permission.camera
            : Permission.photos;

        PermissionStatus status = await permission.request();

        if (!status.isGranted) {
          AppLogger.warning(
            'ProfileController.changeProfilePicture(): permission denied source=$source',
          );
          Get.snackbar(
            'Permission Denied',
            'Please grant ${source == ImageSource.camera ? "camera" : "storage"} permission to continue',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error.withOpacity(0.1),
            colorText: AppColors.error,
          );
          return;
        }

        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 85,
        );

        if (image != null) {
          AppLogger.info(
            'ProfileController.changeProfilePicture(): image selected path=${image.path}',
          );
          final service = Get.find<MockApiService>();
          service.updateProfilePic(image.path);
          profileImageUrl.value = image.path;
          fetchProfile();

          HapticUtils.lightImpact();
          Get.snackbar(
            'Success',
            'Profile picture updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success.withOpacity(0.1),
            colorText: AppColors.success,
          );
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'ProfileController.changeProfilePicture(): failed',
        e,
        stackTrace,
      );
      Get.snackbar(
        'Error',
        'Failed to update profile picture',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
    }
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'streak':
        return Icons.bolt_rounded;
      case 'courses':
        return Icons.auto_stories_rounded;
      case 'quizzes':
        return Icons.quiz_rounded;
      case 'mastery':
        return Icons.emoji_events_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'streak':
        return Colors.orange;
      case 'courses':
        return Colors.blue;
      case 'quizzes':
        return Colors.purple;
      case 'mastery':
        return Colors.amber;
      default:
        return AppColors.primary;
    }
  }

  Future<void> updateProfile() async {
    if (user.value == null) return;

    final nameError = _validationService.validateName(nameValue.value.trim());
    if (nameError != null) {
      AppLogger.warning('ProfileController.updateProfile(): validation failed');
      Get.snackbar('Validation Error', nameError);
      return;
    }

    AppLogger.info('ProfileController.updateProfile(): submitted');
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 1000)); // Mock delay

      final mockApi = Get.find<MockApiService>();
      mockApi.updateProfile(nameValue.value.trim());

      final currentUser = user.value!;
      user.value = currentUser.copyWith(name: nameValue.value.trim());

      final storage = GetStorage();
      storage.write('userName', nameValue.value.trim());
      storage.write('userEmail', emailValue.value.trim());
      storage.write('userPhone', phoneValue.value.trim());

      AppLogger.info('ProfileController.updateProfile(): success');
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'ProfileController.updateProfile(): failed',
        e,
        stackTrace,
      );
      Get.snackbar('Error', 'Failed to update profile.');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleTheme() {
    AppLogger.info('ProfileController.toggleTheme(): toggling theme');
    _themeService.changeThemeMode(!_themeService.isDarkMode());
  }

  bool get isDarkMode => _themeService.isDarkMode();

  void logout() {
    AppLogger.info('ProfileController.logout(): opening confirmation sheet');
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
                      AppLogger.warning(
                        'ProfileController.logout(): confirmed',
                      );
                      final storage = GetStorage();
                      storage.erase(); // Securely remove all user info
                      // storage.write('isFirstLaunch', false);
                      Get.back();
                      Get.offAllNamed(Routes.landing);
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
      AppLogger.warning(
        'ProfileController.changePassword(): validation failed',
      );
      Get.snackbar('Validation Error', newPassError ?? confirmError!);
      return;
    }

    AppLogger.info('ProfileController.changePassword(): submitted');
    isChangingPassword.value = true;
    try {
      await _authService.changePassword(
        currentPasswordController.text,
        newPasswordController.text,
      );
      Get.back(); // Close dialog/view
      Get.snackbar('Success', 'Password changed successfully');

      // Clear fields
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmNewPasswordController.clear();
    } catch (e, stackTrace) {
      AppLogger.error(
        'ProfileController.changePassword(): failed',
        e,
        stackTrace,
      );
      Get.snackbar(
        'Error',
        'Failed to change password. Ensure current password is correct.',
      );
    } finally {
      isChangingPassword.value = false;
    }
  }

  @override
  void onClose() {
    AppLogger.info('ProfileController.onClose(): disposing controllers');
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.onClose();
  }
}

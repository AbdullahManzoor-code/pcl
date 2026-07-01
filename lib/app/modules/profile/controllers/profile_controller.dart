import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pcl/app/data/services/auth_service.dart';
import 'package:pcl/app/routes/app_pages.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/profile_stats_model.dart';
import '../../../data/services/notification_service.dart';
import '../../../data/services/theme_service.dart';
import '../../../data/services/exam_service.dart';
import '../../../data/services/achievement_service.dart';
import '../../../data/services/profile_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/next_components.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pcl/app/services/validation_service.dart';
import '../../../data/models/achievement_model.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/haptic_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/models/exam_api_models.dart';
import '../../../routes/app_pages.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../my_courses/controllers/my_courses_controller.dart';
import '../../courses/controllers/courses_controller.dart';

class ProfileController extends GetxController {
  final _validationService = Get.find<ValidationService>();
  final ThemeService _themeService = Get.find<ThemeService>();
  final NotificationService _notificationService =
      Get.find<NotificationService>();
  final AuthService _authService = Get.find<AuthService>();
  final ExamService _examService = Get.find<ExamService>();
  final AchievementService _achievementService = Get.find<AchievementService>();
  final ProfileService _profileService = Get.find<ProfileService>();

  final user = Rxn<User>();
  final isLoading = true.obs;

  // Real profile stats from server
  final profileStats = Rxn<ProfileStats>();
  final isStatsLoading = false.obs;

  // Profile Form Fields
  final nameValue = ''.obs;
  final usernameValue = ''.obs;
  final emailValue = ''.obs;
  final phoneValue = ''.obs;
  final altEmailValue = ''.obs;
  final profileImageUrl = Rxn<String>();
  final achievements = <Achievement>[].obs;
  final sessionHistory = <SessionHistoryItem>[].obs;

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

  // ── Computed getters from profileStats ─────────────
  int get xp => profileStats.value?.xp ?? 0;
  int get level => profileStats.value?.level ?? 1;
  double get levelProgress => profileStats.value?.levelProgress ?? 0.0;
  int get xpInCurrentLevel => profileStats.value?.xpInCurrentLevel ?? 0;
  int get xpForNextLevel => profileStats.value?.xpRequiredForNextLevel ?? 500;
  int get streakDays => profileStats.value?.streakDays ?? 0;
  int get totalSessions => profileStats.value?.totalSessions ?? 0;
  int get totalTopicsCompleted => profileStats.value?.totalTopicsCompleted ?? 0;
  double get overallAccuracy => profileStats.value?.overallAccuracy ?? 0.0;
  int get totalHours => profileStats.value?.totalHoursEstimate ?? 0;
  String get formattedXP => profileStats.value?.formattedXP ?? '0';
  List<DashboardDecayAlert> get decayAlerts =>
      profileStats.value?.decayAlerts ?? [];
  List<DashboardRecentSession> get recentSessions =>
      profileStats.value?.recentSessions ?? [];
  List<DashboardMasteryData> get masteryData =>
      profileStats.value?.masteryData ?? [];

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
        'ProfileController.fetchProfile(): user loaded email=${realUser.email}',
      );

      final storage = GetStorage();
      final storedName = storage.read('userName') ?? 'User';
      final storedPhone = storage.read('userPhone') ?? '';

      // Initialize form fields
      nameValue.value = realUser.name ?? storedName;
      usernameValue.value = realUser.email?.split('@').first ?? 'user';
      emailValue.value = realUser.email ?? '';
      phoneValue.value = realUser.phone ?? storedPhone;
      altEmailValue.value = realUser.altEmail ?? '';
      profileImageUrl.value =
          realUser.profilePicUrl ?? storage.read('profilePicUrl');

      // Fetch achievements
      try {
        final achData = await _achievementService.getAchievements();
        achievements.assignAll(achData);
      } catch (e) {
        AppLogger.error(
          'ProfileController.fetchProfile(): achievements failed',
          e,
        );
        achievements.assignAll([]);
      }

      // Fetch session history
      try {
        final history = await _examService.getExamHistory(limit: 5);
        sessionHistory.assignAll(history.sessions);
      } catch (e) {
        AppLogger.error(
          'ProfileController.fetchProfile(): session history failed',
          e,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'ProfileController.fetchProfile(): failed',
        e,
        stackTrace,
      );
      Get.snackbar(
        'Error',
        'Failed to load profile. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }

    // Fetch stats in background (non-blocking)
    _fetchProfileStats();
  }

  Future<void> _fetchProfileStats() async {
    AppLogger.info('ProfileController._fetchProfileStats(): start');
    isStatsLoading.value = true;
    try {
      final stats = await _profileService.getProfileStats();
      profileStats.value = stats;
      AppLogger.info(
        'ProfileController._fetchProfileStats(): done '
        'xp=${stats.xp} level=${stats.level} sessions=${stats.totalSessions}',
      );
    } catch (e) {
      AppLogger.error('ProfileController._fetchProfileStats(): failed', e);
    } finally {
      isStatsLoading.value = false;
    }
  }

  /// Refresh stats manually (pull-to-refresh)
  Future<void> refreshStats() async {
    await _fetchProfileStats();
  }

  Future<void> changeProfilePicture() async {
    AppLogger.info('ProfileController.changeProfilePicture(): tapped');
    try {
      final ImagePicker picker = ImagePicker();

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
        profileImageUrl.value = null;
        GetStorage().remove('profilePicUrl');
        user.value = user.value?.copyWith(profilePicUrl: null);
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
        Permission permission = source == ImageSource.camera
            ? Permission.camera
            : Permission.photos;
        PermissionStatus status = await permission.request();
        if (!status.isGranted) {
          Get.snackbar(
            'Permission Denied',
            'Please grant ${source == ImageSource.camera ? "camera" : "storage"} permission',
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
          profileImageUrl.value = image.path;
          GetStorage().write('profilePicUrl', image.path);
          user.value = user.value?.copyWith(profilePicUrl: image.path);
          HapticUtils.lightImpact();
          Get.snackbar(
            'Success',
            'Profile picture updated',
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
      Get.snackbar('Error', 'Failed to update profile picture');
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
    final Map<String, dynamic> changes = {};
    if (nameValue.value.trim() != user.value?.name) {
      changes['name'] = nameValue.value.trim();
    }
    if (emailValue.value.trim() != user.value?.email) {
      changes['email'] = emailValue.value.trim();
    }
    if (phoneValue.value.trim() != user.value?.phone) {
      changes['phone'] = phoneValue.value.trim();
    }
    if (altEmailValue.value.trim() != user.value?.altEmail) {
      changes['alt_email'] = altEmailValue.value.trim();
    }

    if (changes.isEmpty) {
      isLoading.value = false;
      Get.snackbar('Info', 'No changes to save.');
      return;
    }

    try {
      final updatedUser = await _authService.updateProfile(changes);
      user.value = updatedUser;
      Get.back();
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withOpacity(0.1),
        colorText: AppColors.success,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'ProfileController.updateProfile(): failed',
        e,
        stackTrace,
      );
      Get.snackbar('Error', 'Failed to update profile. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleTheme() {
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
              'Are you sure you want to logout?',
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
                      final storage = GetStorage();
                      storage.erase();
                      
                      // Delete controllers to clear memory so next login fetches fresh data
                      Get.delete<DashboardController>(force: true);
                      Get.delete<MyCoursesController>(force: true);
                      Get.delete<CoursesController>(force: true);
                      
                      Get.back();
                      Get.offAllNamed(Routes.auth);
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
      await _authService.changePassword(
        currentPasswordController.text,
        newPasswordController.text,
      );
      Get.back();
      Get.snackbar('Success', 'Password changed successfully');
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
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.onClose();
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/profile_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/next_components.dart';
import '../../../core/utils/responsive_view.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: ResponsiveView(
          mobile: SingleChildScrollView(
            padding: EdgeInsets.all(24.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildSettingsContent(context, isDark),
            ),
          ),
          desktop: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 900.w),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(40.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildSettingsContent(context, isDark),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSettingsContent(BuildContext context, bool isDark) {
    return [
      // Header
      SizedBox(height: 16.h),
      ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [AppColors.violet600, AppColors.primary, AppColors.violet600],
        ).createShader(bounds),
        child: Text(
          'Settings',
          style: GoogleFonts.inter(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      SizedBox(height: 8.h),
      Text(
        'Settings and preferences',
        style: GoogleFonts.inter(
          fontSize: 10.sp,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
      ),
      SizedBox(height: 32.h),

      // Note: _buildProfileForm matches the design in the original code
      _buildProfileForm(context),
      SizedBox(height: 24.h),

      // Appearance Settings
      _buildSection(
        context,
        title: 'Appearance',
        subtitle: 'Customize appearance',
        icon: Icons.palette_rounded,
        iconGradient: [
          const Color.fromARGB(255, 239, 179, 192),
          AppColors.violet600,
        ],
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      'Toggle Theme mode',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: controller.isDarkMode,
                  onChanged: (_) => controller.toggleTheme(),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            const Divider(height: 1),
            SizedBox(height: 16.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Color Preview',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                _buildColorPreview(context, 'Primary', [
                  AppColors.primary,
                  AppColors.violet600,
                ]),
                const SizedBox(width: 12),
                _buildColorPreview(context, 'Secondary', [
                  AppColors.success,
                  AppColors.emerald600,
                ]),
                SizedBox(width: 12.w),
                _buildColorPreview(context, 'Accent', [
                  AppColors.rose600,
                  AppColors.pink600,
                ]),
              ],
            ),
          ],
        ),
      ),
      SizedBox(height: 24.h),

      // Notification Settings
      _buildSection(
        context,
        title: 'Notifications',
        subtitle: 'Notification preferences',
        icon: Icons.notifications_rounded,
        iconGradient: [
          const Color(0xFFEAB308),
          const Color(0xFFEA580C),
        ], // Yellow to Orange
        child: Column(
          children: [
            Obx(
              () => _buildToggleRow(
                context,
                'Email Notifications',
                'Receive email updates about your learning progress',
                controller.emailNotifications.value,
                (v) => controller.emailNotifications.value = v,
              ),
            ),
            SizedBox(height: 16.h),
            Obx(
              () => _buildToggleRow(
                context,
                'Test Reminders',
                'Get reminders to complete pending tests',
                controller.testReminders.value,
                (v) => controller.testReminders.value = v,
              ),
            ),
            SizedBox(height: 16.h),
            Obx(
              () => _buildToggleRow(
                context,
                'Weekly Progress',
                'Receive weekly summaries of your learning activity',
                controller.weeklyProgress.value,
                (v) => controller.weeklyProgress.value = v,
              ),
            ),
            SizedBox(height: 16.h),
            Obx(
              () => _buildToggleRow(
                context,
                'Achievement Alerts',
                'Get notified when you unlock achievements',
                controller.achievementAlerts.value,
                (v) => controller.achievementAlerts.value = v,
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 24.h),

      // Security Settings
      _buildSection(
        context,
        title: 'Security',
        subtitle: 'Manage your account security',
        icon: Icons.security_rounded,
        iconGradient: [
          const Color(0xFFEF4444),
          const Color(0xFFE11D48),
        ], // Red to Rose
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Password',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            Text(
              'Change your password to keep your account secure',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            SizedBox(height: 12.h),
            NextButton(
              text: 'Change Password',
              onPressed: () {},
              outline: true,
              isFullWidth: false,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: const Divider(height: 1),
            ),
            Text(
              'Delete Account',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFEF4444),
              ),
            ),
            Text(
              'Permanently delete your account and all associated data',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            SizedBox(height: 12.h),
            NextButton(
              text: 'Delete Account',
              onPressed: controller.logout,
              color: AppColors.error,
              icon: Icons.delete_outline_rounded,
            ),
          ],
        ),
      ),
      SizedBox(height: 32.h),
    ];
  }

  Widget _buildProfileForm(BuildContext context) {
    // We create controllers locally or use existing ones if passed, but easiest is to pass initial value
    // and handle onChanged in UI if NextInput allows, or just use regular TextField for simplicity in refactor
    // Since NextInput is available, let's use it but we need to update observables manually.

    // NOTE: In a real app, these controllers should be in GetIndexController to persist text
    final TextEditingController nameCtl = TextEditingController(
      text: controller.nameValue.value,
    );
    final TextEditingController userCtl = TextEditingController(
      text: controller.usernameValue.value,
    );
    final TextEditingController emailCtl = TextEditingController(
      text: controller.emailValue.value,
    );

    // Update observables when text changes
    nameCtl.addListener(() => controller.nameValue.value = nameCtl.text);
    // ...

    return _buildSection(
      context,
      title: 'Profile Information',
      subtitle: 'Update personal information',
      icon: Icons.person_rounded,
      iconGradient: [const Color(0xFF3B82F6), const Color(0xFF9333EA)],
      child: Column(
        children: [
          NextInput(label: 'Full Name', controller: nameCtl),
          SizedBox(height: 16.h),
          NextInput(label: 'Username', controller: userCtl),
          SizedBox(height: 16.h),
          NextInput(
            label: 'Email',
            controller: emailCtl,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 24.h),
          NextButton(
            text: 'Save Changes',
            onPressed: controller.updateProfile,
            icon: Icons.save_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> iconGradient,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NextCard(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: iconGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: iconGradient[0].withOpacity(0.1),
                        blurRadius: 8.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp, // Matching CardTitle
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 10.sp, // CardDescription
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24.h),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF2563EB),
        ),
      ],
    );
  }

  Widget _buildColorPreview(
    BuildContext context,
    String label,
    List<Color> colors,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Column(
        children: [
          Container(
            height: 64.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: [
                BoxShadow(
                  color: colors[0].withOpacity(0.1),
                  blurRadius: 8.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import '../controllers/profile_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/next_components.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../data/models/achievement_model.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(context, isDark),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                child: Column(children: _buildSettingsContent(context, isDark)),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 280.h,
      pinned: true,
      stretch: true,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: _buildUserBanner(context, isDark),
      ),
    );
  }

  Widget _buildUserBanner(BuildContext context, bool isDark) {
    final user = controller.user.value;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.violet600],
        ),
      ),
      child: Stack(
        children: [
          // Subtle background patterns
          Positioned(
            right: -30.w,
            top: -20.h,
            child: CircleAvatar(
              radius: 100.r,
              backgroundColor: Colors.white.withOpacity(0.05),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'profile_avatar',
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Obx(() {
                          final profilePic = controller.profileImageUrl.value;
                          return CircleAvatar(
                            radius: 50.r,
                            backgroundColor: Colors.white24,
                            backgroundImage:
                                profilePic != null && profilePic.isNotEmpty
                                ? FileImage(File(profilePic)) as ImageProvider
                                : null,
                            child: profilePic == null || profilePic.isEmpty
                                ? Text(
                                    (user?.name ?? 'U')[0].toUpperCase(),
                                    style: GoogleFonts.outfit(
                                      fontSize: 40.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          );
                        }),
                        Positioned.fill(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => controller.changeProfilePicture(),
                              borderRadius: BorderRadius.circular(50.r),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(4.r),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 14.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  user?.name ?? 'Loading...',
                  style: GoogleFonts.outfit(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  user?.email ?? 'mian@example.com',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatBadge(
                      Icons.auto_awesome_rounded,
                      controller.user.value?.stats?.totalXP != null
                          ? 'XP ${controller.user.value?.stats!.totalXP}'
                          : 'XP 1',
                    ),
                    SizedBox(width: 12.w),
                    _buildStatBadge(
                      Icons.workspace_premium_rounded,
                      'Level ${controller.user.value?.stats?.totalHours ?? 1}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14.sp),
          SizedBox(width: 6.w),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSettingsContent(BuildContext context, bool isDark) {
    return [
      _buildAchievementGallery(context, isDark),
      SizedBox(height: 32.h),
      _buildSettingsGroup(context, 'Account Settings', [
        _buildSettingActionRow(
          context,
          'Profile Information',
          'Update your personal data',
          () => _showEditProfileSheet(context),
          icon: Icons.person_outline_rounded,
          iconColor: AppColors.primary,
        ),
        _buildSettingActionRow(
          context,
          'Email Address',
          controller.emailValue.value,
          () {},
          icon: Icons.alternate_email_rounded,
          iconColor: Colors.blue,
        ),
        _buildSettingActionRow(
          context,
          'Phone Number',
          controller.phoneValue.value,
          () {},
          icon: Icons.phone_iphone_rounded,
          iconColor: Colors.teal,
        ),
      ]),
      SizedBox(height: 24.h),
      _buildSettingsGroup(context, 'Preferences', [
        _buildToggleTile(
          context,
          'Dark Mode',
          'Switch between light and dark themes',
          controller.isDarkMode,
          (_) => controller.toggleTheme(),
          icon: Icons.dark_mode_outlined,
          iconColor: Colors.amber,
        ),
        _buildSettingActionRow(
          context,
          'Notifications',
          'Configure your alerts',
          () {},
          icon: Icons.notifications_none_rounded,
          iconColor: Colors.orange,
        ),
      ]),
      SizedBox(height: 24.h),
      _buildSettingsGroup(context, 'Security', [
        _buildSettingActionRow(
          context,
          'Change Password',
          'Secure your account',
          () => Get.toNamed(Routes.changePassword),
          icon: Icons.lock_outline_rounded,
          iconColor: AppColors.error,
        ),
        _buildSettingActionRow(
          context,
          'Two-Factor Auth',
          'Add extra protection',
          () {},
          icon: Icons.verified_user_outlined,
          iconColor: AppColors.success,
        ),
      ]),
      SizedBox(height: 24.h),
      _buildSettingsGroup(context, 'Support & Legal', [
        _buildSettingActionRow(
          context,
          'Help Center',
          'Get instant help',
          () => _showPlaceholderSheet(context, 'Help Center'),
          icon: Icons.help_outline_rounded,
          iconColor: Colors.indigo,
        ),
        _buildSettingActionRow(
          context,
          'Privacy Policy',
          'Read our terms',
          () => _showPlaceholderSheet(context, 'Privacy Policy'),
          icon: Icons.description_outlined,
          iconColor: Colors.grey,
        ),
        _buildSettingActionRow(
          context,
          'Terms of Service',
          'Legal agreements',
          () => _showPlaceholderSheet(context, 'Terms of Service'),
          icon: Icons.gavel_rounded,
          iconColor: Colors.blueGrey,
        ),
      ]),
      SizedBox(height: 40.h),
      NextButton(
        text: 'Sign Out',
        onPressed: () => controller.logout(),
        color: AppColors.error,
        icon: Icons.logout_rounded,
        isFullWidth: true,
      ),
      SizedBox(height: 40.h),
    ];
  }

  void _showPlaceholderSheet(BuildContext context, String title) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(32.r),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
              size: 48.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'This module is currently under development to provide you with the best experience.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey),
            ),
            SizedBox(height: 32.h),
            NextButton(
              text: 'Got it',
              onPressed: () => Get.back(),
              isFullWidth: true,
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showEditProfileSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [_buildProfileForm(context)],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildSettingsGroup(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 12.w, bottom: 8.h),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final idx = entry.key;
              final child = entry.value;
              return Column(
                children: [
                  child,
                  if (idx < children.length - 1)
                    Divider(
                      height: 1,
                      indent: 60.w,
                      endIndent: 20.w,
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleTile(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged, {
    required IconData icon,
    required Color iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            _buildTileIcon(icon, iconColor, isDark),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTileIcon(IconData icon, Color color, bool isDark) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(icon, color: color, size: 20.sp),
    );
  }

  Widget _buildAchievementGallery(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 12.w, bottom: 16.h),
          child: Text(
            'Achievements'.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        SizedBox(
          height: 140.h,
          child: Obx(
            () => ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: controller.achievements.length,
              separatorBuilder: (_, __) => SizedBox(width: 16.w),
              itemBuilder: (context, index) {
                final ach = controller.achievements[index];
                return _buildAchievementCard(context, ach, isDark);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(
    BuildContext context,
    Achievement ach,
    bool isDark,
  ) {
    final color = ach.isUnlocked ? ach.color : Colors.grey;
    return Container(
      width: 100.w,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: ach.isUnlocked
              ? color.withOpacity(0.5)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: 2,
        ),
        boxShadow: ach.isUnlocked
            ? [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              ach.icon,
              color: ach.isUnlocked ? color : Colors.grey.shade400,
              size: 24.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            ach.title,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: ach.isUnlocked
                  ? (isDark ? Colors.white : Colors.black)
                  : Colors.grey,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (!ach.isUnlocked) ...[
            SizedBox(height: 4.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: ach.currentProgress / ach.requiredCount,
                backgroundColor: Colors.grey.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation(Colors.grey),
                minHeight: 4.h,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileForm(BuildContext context) {
    final TextEditingController nameCtl = TextEditingController(
      text: controller.nameValue.value,
    );
    final TextEditingController userCtl = TextEditingController(
      text: controller.usernameValue.value,
    );
    final TextEditingController emailCtl = TextEditingController(
      text: controller.emailValue.value,
    );
    final TextEditingController phoneCtl = TextEditingController(
      text: controller.phoneValue.value,
    );

    return Column(
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Edit Profile',
              style: GoogleFonts.outfit(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        _buildEditSection(context, 'Basic Information', [
          NextInput(label: 'Full Name', controller: nameCtl),
          SizedBox(height: 16.h),
          NextInput(label: 'Username', controller: userCtl),
        ]),
        SizedBox(height: 24.h),
        _buildEditSection(context, 'Contact Details', [
          NextInput(
            label: 'Email Address',
            controller: emailCtl,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 16.h),
          NextInput(
            label: 'Phone Number',
            controller: phoneCtl,
            keyboardType: TextInputType.phone,
          ),
        ]),
        SizedBox(height: 32.h),
        NextButton(
          text: 'Save Changes',
          onPressed: () {
            controller.nameValue.value = nameCtl.text;
            controller.usernameValue.value = userCtl.text;
            controller.emailValue.value = emailCtl.text;
            controller.phoneValue.value = phoneCtl.text;
            controller.updateProfile();
            Get.back();
          },
          isFullWidth: true,
          icon: Icons.check_circle_outline_rounded,
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildEditSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        SizedBox(height: 16.h),
        ...children,
      ],
    );
  }

  Widget _buildSettingActionRow(
    BuildContext context,
    String title,
    String subtitle,
    VoidCallback onTap, {
    IconData? icon,
    Color? iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        HapticUtils.lightImpact();
        onTap();
      },
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            if (icon != null) ...[
              _buildTileIcon(icon, iconColor ?? AppColors.primary, isDark),
              SizedBox(width: 16.w),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.sp,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'dart:math' as math;
import '../controllers/profile_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/datetime_utils.dart';
import '../../../core/widgets/next_components.dart';
import '../../../core/widgets/shimmer_widgets.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../data/models/achievement_model.dart';
import '../../../data/models/profile_stats_model.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF5F7FA),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState(isDark);
        }
        return RefreshIndicator(
          onRefresh: controller.refreshStats,
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context, isDark),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // ── Stats overview row ────────────────────
                    _buildStatsOverviewRow(context, isDark),
                    SizedBox(height: 16.h),
                    // ── Level progress card ───────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: _buildLevelProgressCard(context, isDark),
                    ),
                    SizedBox(height: 16.h),
                    // ── Mastery / Decay alerts ────────────────
                    Obx(() {
                      final alerts = controller.decayAlerts;
                      if (alerts.isNotEmpty) {
                        return Column(
                          children: [
                            _buildSectionHeader(
                              'Knowledge Decay Alerts',
                              isDark,
                              subtitle: 'Topics losing mastery from inactivity',
                            ),
                            SizedBox(height: 8.h),
                            ...alerts.map(
                              (a) => _buildDecayAlertCard(context, a, isDark),
                            ),
                            SizedBox(height: 16.h),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    // ── Recent sessions ───────────────────────
                    Obx(() {
                      final sessions = controller.recentSessions;
                      if (sessions.isNotEmpty) {
                        return Column(
                          children: [
                            _buildSectionHeader(
                              'Recent Sessions',
                              isDark,
                              subtitle: 'Your last quiz performances',
                              action: GestureDetector(
                                onTap: () => Get.toNamed(Routes.resultHistory),
                                child: Text(
                                  'View All',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: Column(
                                children: sessions
                                    .map(
                                      (s) =>
                                          _buildSessionCard(context, s, isDark),
                                    )
                                    .toList(),
                              ),
                            ),
                            SizedBox(height: 16.h),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    // ── Mastery breakdown ─────────────────────
                    Obx(() {
                      final mastery = controller.masteryData;
                      if (mastery.isNotEmpty) {
                        return Column(
                          children: [
                            _buildSectionHeader(
                              'Topic Mastery',
                              isDark,
                              subtitle: 'Your knowledge across all topics',
                            ),
                            SizedBox(height: 8.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: _buildMasteryGrid(
                                context,
                                mastery,
                                isDark,
                              ),
                            ),
                            SizedBox(height: 16.h),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    // ── Achievements ──────────────────────────
                    // _buildAchievementsSection(context, isDark),
                    SizedBox(height: 16.h),
                    // ── Settings groups ───────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        children: [
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
                              controller.phoneValue.value.isEmpty
                                  ? 'Not set'
                                  : controller.phoneValue.value,
                              () {},
                              icon: Icons.phone_iphone_rounded,
                              iconColor: AppColors.primary,
                            ),
                          ]),
                          SizedBox(height: 20.h),
                          _buildSettingsGroup(context, 'Preferences', [
                            _buildToggleTile(
                              context,
                              'Dark Mode',
                              'Switch between light and dark themes',
                              controller.isDarkMode,
                              (_) => controller.toggleTheme(),
                              icon: Icons.dark_mode_outlined,
                              iconColor: AppColors.primary,
                            ),
                            _buildSettingActionRow(
                              context,
                              'Notifications',
                              'Configure your alerts',
                              () => Get.toNamed(Routes.notifications),
                              icon: Icons.notifications_none_rounded,
                              iconColor: AppColors.primary,
                            ),
                          ]),
                          SizedBox(height: 20.h),
                          _buildSettingsGroup(context, 'Security', [
                            _buildSettingActionRow(
                              context,
                              'Change Password',
                              'Secure your account',
                              () => Get.toNamed(Routes.changePassword),
                              icon: Icons.lock_outline_rounded,
                              iconColor: AppColors.primary,
                            ),
                          ]),
                          SizedBox(height: 20.h),
                          _buildSettingsGroup(context, 'Support & Legal', [
                            _buildSettingActionRow(
                              context,
                              'Help Center',
                              'Get instant help',
                              () =>
                                  _showPlaceholderSheet(context, 'Help Center'),
                              icon: Icons.help_outline_rounded,
                              iconColor: AppColors.primary,
                            ),
                            _buildSettingActionRow(
                              context,
                              'Privacy Policy',
                              'Read our terms',
                              () => _showPlaceholderSheet(
                                context,
                                'Privacy Policy',
                              ),
                              icon: Icons.description_outlined,
                              iconColor: AppColors.primary,
                            ),
                          ]),
                          SizedBox(height: 32.h),
                          NextButton(
                            text: 'Sign Out',
                            onPressed: () => controller.logout(),
                            color: AppColors.error,
                            icon: Icons.logout_rounded,
                            isFullWidth: true,
                          ),
                          SizedBox(height: 48.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // HERO SLIVER APP BAR
  // ══════════════════════════════════════════════════════════════════

  Widget _buildSliverAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 300.h,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: _buildUserBanner(context, isDark),
      ),
    );
  }

  Widget _buildUserBanner(BuildContext context, bool isDark) {
    final user = controller.user.value;
    final initials = _getInitials(user?.name ?? user?.email ?? 'U');

    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
      child: Container(
        decoration: BoxDecoration(gradient: AppColors.heroGradient),
        child: Stack(
          children: [
            // Background decorative circles
            Positioned(
              right: -40.w,
              top: -30.h,
              child: Container(
                width: 200.w,
                height: 200.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              left: -60.w,
              bottom: 20.h,
              child: Container(
                width: 160.w,
                height: 160.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
            // Main content
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 12.h),
                  // Avatar
                  Hero(
                    tag: 'profile_avatar',
                    child: Container(
                      padding: EdgeInsets.all(3.r),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.8),
                            Colors.white.withOpacity(0.3),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Obx(() {
                            final pic = controller.profileImageUrl.value;
                            return CircleAvatar(
                              radius: 48.r,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              backgroundImage: pic != null && pic.isNotEmpty
                                  ? FileImage(File(pic)) as ImageProvider
                                  : null,
                              child: pic == null || pic.isEmpty
                                  ? Text(
                                      initials,
                                      style: GoogleFonts.outfit(
                                        fontSize: 36.sp,
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
                              padding: EdgeInsets.all(5.r),
                              decoration: BoxDecoration(
                                color: const Color(0xFF34D399),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    user?.name ?? user?.email?.split('@').first ?? 'User',
                    style: GoogleFonts.outfit(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    user?.email ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: Colors.white.withOpacity(0.75),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // XP + Level chips
                  Obx(() {
                    final loading = controller.isStatsLoading.value;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildHeroBadge(
                          Icons.auto_awesome_rounded,
                          loading ? '...' : '${controller.formattedXP} XP',
                          const Color(0xFFFBBF24),
                        ),
                        SizedBox(width: 10.w),
                        _buildHeroBadge(
                          Icons.workspace_premium_rounded,
                          loading ? '...' : 'Level ${controller.level}',
                          const Color(0xFF34D399),
                        ),
                        SizedBox(width: 10.w),
                        _buildHeroBadge(
                          Icons.local_fire_department_rounded,
                          loading ? '...' : '${controller.streakDays}d streak',
                          const Color(0xFFF87171),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBadge(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon(icon, color: color, size: 14.sp),
          // SizedBox(width: 5.w),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // STATS OVERVIEW ROW
  // ══════════════════════════════════════════════════════════════════

  Widget _buildStatsOverviewRow(BuildContext context, bool isDark) {
    return Obx(() {
      final loading = controller.isStatsLoading.value;
      return Container(
        margin: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
        padding: EdgeInsets.symmetric(vertical: 18.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildStatColumn(
              '',
              loading
                  ? '—'
                  : '${controller.overallAccuracy.toStringAsFixed(0)}%',
              'Accuracy',
              isDark,
            ),
            _buildStatDivider(isDark),
            _buildStatColumn(
              '',
              loading ? '—' : '${controller.totalTopicsCompleted}',
              'Topics Done',
              isDark,
            ),
            _buildStatDivider(isDark),
            _buildStatColumn(
              '',
              loading ? '—' : '${controller.totalSessions}',
              'Quizzes',
              isDark,
            ),
            _buildStatDivider(isDark),
            _buildStatColumn(
              '',
              loading ? '—' : '${controller.totalHours}h',
              'Est. Hours',
              isDark,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatColumn(
    String emoji,
    String value,
    String label,
    bool isDark,
  ) {
    return Expanded(
      child: Column(
        children: [
          // Text(emoji, style: TextStyle(fontSize: 20.sp)),
          // SizedBox(height: 6.h),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider(bool isDark) {
    return Container(
      width: 1,
      height: 40.h,
      color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // LEVEL PROGRESS CARD
  // ══════════════════════════════════════════════════════════════════

  Widget _buildLevelProgressCard(BuildContext context, bool isDark) {
    return Obx(() {
      final loading = controller.isStatsLoading.value;
      final progress = controller.levelProgress.clamp(0.0, 1.0);
      final xpIn = controller.xpInCurrentLevel;
      final xpNeeded = controller.xpForNextLevel;

      return Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkTextPrimary.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level ${controller.level}',
                      style: GoogleFonts.outfit(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _getLevelTitle(controller.level),
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 64.w,
                  height: 64.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getLevelEmoji(controller.level),
                      style: TextStyle(fontSize: 28.sp),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loading ? 'Loading XP...' : '$xpIn / $xpNeeded XP',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  loading ? '' : 'Next: Level ${controller.level + 1}',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.65),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: loading ? 0.0 : progress),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (_, val, __) => LinearProgressIndicator(
                  value: val,
                  minHeight: 10.h,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFFBBF24)),
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: const Color(0xFFFBBF24),
                  size: 14.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  loading
                      ? 'Calculating...'
                      : '${controller.formattedXP} total XP earned',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  // ══════════════════════════════════════════════════════════════════
  // DECAY ALERT CARD
  // ══════════════════════════════════════════════════════════════════

  Widget _buildDecayAlertCard(
    BuildContext context,
    DashboardDecayAlert alert,
    bool isDark,
  ) {
    final decayPct = alert.decayPercent;
    final severity = decayPct > 30
        ? 'high'
        : (decayPct > 15 ? 'medium' : 'low');
    final color = severity == 'high'
        ? const Color(0xFFEF4444)
        : severity == 'medium'
        ? const Color(0xFFF59E0B)
        : const Color(0xFF6B7280);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.trending_down_rounded,
                color: color,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.conceptName,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    '${alert.daysPassed}d inactive · '
                    '${(alert.currentMastery * 100).toStringAsFixed(0)}% mastery '
                    '(↓${decayPct.toStringAsFixed(0)}%)',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Review',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // RECENT SESSIONS
  // ══════════════════════════════════════════════════════════════════

  Widget _buildSessionCard(
    BuildContext context,
    DashboardRecentSession session,
    bool isDark,
  ) {
    final score = (session.score * 100).round();
    final scoreColor = score >= 70
        ? const Color(0xFF10B981)
        : score >= 50
        ? const Color(0xFFF59E0B)
        : const Color(0xFFEF4444);
    final dt = session.parsedTimestamp;
    final dateLabel = dt != null ? _formatDate(dt) : '';
    final difficulty = _difficultyLabel(session.difficulty);

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Score circle
          Container(
            width: 52.w,
            height: 52.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scoreColor.withOpacity(0.12),
              border: Border.all(color: scoreColor.withOpacity(0.5), width: 2),
            ),
            child: Center(
              child: Text(
                '$score%',
                style: GoogleFonts.outfit(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.conceptName,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    _buildTag(difficulty.label, difficulty.color),
                    SizedBox(width: 6.w),
                    _buildTag('${session.questionsAnswered}Q', Colors.blueGrey),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            dateLabel,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 9.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // MASTERY GRID
  // ══════════════════════════════════════════════════════════════════

  Widget _buildMasteryGrid(
    BuildContext context,
    List<DashboardMasteryData> mastery,
    bool isDark,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 1.8,
      ),
      itemCount: mastery.length,
      itemBuilder: (_, i) => _buildMasteryTile(mastery[i], isDark),
    );
  }

  Widget _buildMasteryTile(DashboardMasteryData data, bool isDark) {
    final pct = (data.mastery * 100).round();
    final decayPct = (data.decayedMastery * 100).round();
    final color = pct >= 75
        ? const Color(0xFF10B981)
        : pct >= 50
        ? const Color(0xFF3B82F6)
        : pct >= 25
        ? const Color(0xFFF59E0B)
        : const Color(0xFFEF4444);

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            data.name,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF334155),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Text(
                '$pct%',
                style: GoogleFonts.outfit(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (decayPct < pct) ...[
                SizedBox(width: 4.w),
                Text(
                  '→$decayPct%',
                  style: GoogleFonts.inter(
                    fontSize: 9.sp,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: data.mastery.clamp(0.0, 1.0),
              minHeight: 5.h,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  // // ══════════════════════════════════════════════════════════════════
  // // ACHIEVEMENTS
  // // ══════════════════════════════════════════════════════════════════

  // Widget _buildAchievementsSection(BuildContext context, bool isDark) {
  //   return Obx(() {
  //     if (controller.achievements.isEmpty) return const SizedBox.shrink();
  //     return Column(
  //       children: [
  //         _buildSectionHeader('🏆  Achievements', isDark,
  //             subtitle: '${controller.achievements.where((a) => a.isUnlocked).length} of ${controller.achievements.length} unlocked'),
  //         SizedBox(height: 8.h),
  //         SizedBox(
  //           height: 140.h,
  //           child: ListView.separated(
  //             scrollDirection: Axis.horizontal,
  //             padding: EdgeInsets.symmetric(horizontal: 20.w),
  //             physics: const BouncingScrollPhysics(),
  //             itemCount: controller.achievements.length,
  //             separatorBuilder: (_, __) => SizedBox(width: 12.w),
  //             itemBuilder: (ctx, i) =>
  //                 _buildAchievementCard(ctx, controller.achievements[i], isDark),
  //           ),
  //         ),
  //         SizedBox(height: 16.h),
  //       ],
  //     );
  //   });
  // }

  // Widget _buildAchievementCard(
  //     BuildContext context, Achievement ach, bool isDark) {
  //   final color = ach.isUnlocked ? ach.color : Colors.grey;
  //   return Container(
  //     width: 100.w,
  //     padding: EdgeInsets.all(12.r),
  //     decoration: BoxDecoration(
  //       color: isDark ? AppColors.darkSurface : Colors.white,
  //       borderRadius: BorderRadius.circular(20.r),
  //       border: Border.all(
  //         color: ach.isUnlocked
  //             ? color.withOpacity(0.4)
  //             : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
  //         width: 2,
  //       ),
  //       boxShadow: ach.isUnlocked
  //           ? [
  //               BoxShadow(
  //                 color: color.withOpacity(0.12),
  //                 blurRadius: 12,
  //                 offset: const Offset(0, 4),
  //               ),
  //             ]
  //           : null,
  //     ),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Container(
  //           padding: EdgeInsets.all(10.r),
  //           decoration: BoxDecoration(
  //             color: color.withOpacity(0.1),
  //             shape: BoxShape.circle,
  //           ),
  //           child: Icon(ach.icon,
  //               color: ach.isUnlocked ? color : Colors.grey.shade400,
  //               size: 22.sp),
  //         ),
  //         SizedBox(height: 8.h),
  //         Text(
  //           ach.title,
  //           style: GoogleFonts.inter(
  //             fontSize: 10.sp,
  //             fontWeight: FontWeight.bold,
  //             color: ach.isUnlocked
  //                 ? (isDark ? Colors.white : Colors.black)
  //                 : Colors.grey,
  //           ),
  //           textAlign: TextAlign.center,
  //           maxLines: 2,
  //           overflow: TextOverflow.ellipsis,
  //         ),
  //         if (!ach.isUnlocked) ...[
  //           SizedBox(height: 4.h),
  //           ClipRRect(
  //             borderRadius: BorderRadius.circular(4.r),
  //             child: LinearProgressIndicator(
  //               value: ach.currentProgress / math.max(ach.requiredCount, 1),
  //               backgroundColor: Colors.grey.withOpacity(0.1),
  //               valueColor: const AlwaysStoppedAnimation(Colors.grey),
  //               minHeight: 3.h,
  //             ),
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }

  // ══════════════════════════════════════════════════════════════════
  // SECTION HEADER
  // ══════════════════════════════════════════════════════════════════

  Widget _buildSectionHeader(
    String title,
    bool isDark, {
    String? subtitle,
    Widget? action,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
              ],
            ),
          ),
          if (action != null) action,
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // SETTINGS COMPONENTS
  // ══════════════════════════════════════════════════════════════════

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
          padding: EdgeInsets.only(left: 4.w, bottom: 10.h),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11.sp,
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
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final idx = entry.key;
              return Column(
                children: [
                  entry.value,
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
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            _buildTileIcon(icon, iconColor),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
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

  Widget _buildTileIcon(IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(icon, color: color, size: 18.sp),
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
      borderRadius: BorderRadius.circular(20.r),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            if (icon != null) ...[
              _buildTileIcon(icon, iconColor ?? AppColors.primary),
              SizedBox(width: 14.w),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13.sp,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // EDIT PROFILE SHEET
  // ══════════════════════════════════════════════════════════════════

  void _showEditProfileSheet(BuildContext context) {
    final nameCtl = TextEditingController(text: controller.nameValue.value);
    final emailCtl = TextEditingController(text: controller.emailValue.value);
    final phoneCtl = TextEditingController(text: controller.phoneValue.value);

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 20.h),
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
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            NextInput(label: 'Full Name', controller: nameCtl),
            SizedBox(height: 14.h),
            NextInput(
              label: 'Email Address',
              controller: emailCtl,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 14.h),
            NextInput(
              label: 'Phone Number',
              controller: phoneCtl,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 24.h),
            NextButton(
              text: 'Save Changes',
              onPressed: () {
                controller.nameValue.value = nameCtl.text;
                controller.emailValue.value = emailCtl.text;
                controller.phoneValue.value = phoneCtl.text;
                controller.updateProfile();
              },
              isFullWidth: true,
              icon: Icons.check_circle_outline_rounded,
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
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
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
              size: 48.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Coming soon.',
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

  // ══════════════════════════════════════════════════════════════════
  // LOADING STATE
  // ══════════════════════════════════════════════════════════════════

  Widget _buildLoadingState(bool isDark) {
    return const ProfileShimmer();
  }

  // ══════════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════════

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'[\s@]+'));
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String _getLevelTitle(int level) {
    if (level <= 2) return 'Beginner';
    if (level <= 5) return 'Apprentice';
    if (level <= 9) return 'Practitioner';
    if (level <= 14) return 'Expert';
    if (level <= 19) return 'Master';
    return 'Grand Master';
  }

  String _getLevelEmoji(int level) {
    if (level <= 2) return '🌱';
    if (level <= 5) return '⚡';
    if (level <= 9) return '🔥';
    if (level <= 14) return '💎';
    if (level <= 19) return '🚀';
    return '👑';
  }

  String _formatDate(DateTime dt) {
    return DateTimeUtils.formatSimpleDate(dt);
  }

  ({String label, Color color}) _difficultyLabel(double d) {
    if (d < 0.35) return (label: 'Easy', color: const Color(0xFF10B981));
    if (d < 0.65) return (label: 'Medium', color: const Color(0xFFF59E0B));
    return (label: 'Hard', color: const Color(0xFFEF4444));
  }
}

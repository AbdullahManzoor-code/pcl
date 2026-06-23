import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animated_widgets.dart';
import '../../../core/widgets/special_cards.dart';
import '../../../core/utils/haptic_utils.dart';
import '../controllers/dashboard_controller.dart';
import '../../../data/models/course_model.dart';
import '../../../core/widgets/heatmap.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar(
              automaticallyImplyLeading: true,
              titleSpacing: 0,
              pinned: true,
              floating: false,
              backgroundColor: AppColors.primary,
              elevation: 10,
              scrolledUnderElevation: 0,
              toolbarHeight: 50.h,
              forceElevated: innerBoxIsScrolled,
              title: _renderTitle(context),
              bottom: _buildHeaderCard(context),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20.r),
                ),
              ),
            ),
          ),
        ],
        body: Builder(
          builder: (BuildContext context) {
            return RefreshIndicator(
              onRefresh: () async => controller.fetchData(),
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              color: AppColors.primary,
              edgeOffset: 150.h,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                      context,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.h), // Spacing after overlap
                          // SizedBox(height: 24.h),
                          // Obx(
                          //   () => TransferBoostAlert(
                          //     boosts: controller.transferBoosts,
                          //   ),
                          // ),
                          // Obx(
                          //   () => SynergyBonusCard(
                          //     bonuses: controller.synergyBonuses,
                          //   ),
                          // ),
                          Obx(
                            () => LearningHeatmap(
                              data: controller.heatmapDays,
                              selectedFilter: controller.heatmapFilter,
                              isLoading: controller.isHeatmapLoading.value,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          _buildQuickActions(context),
                          SizedBox(height: 32.h),
                          _buildAISuggestion(context),
                          SizedBox(height: 32.h),
                          _buildSectionHeader(context, 'Continue Learning', () {
                            controller.goToMyCourses();
                          }),
                          SizedBox(height: 16.h),
                          _buildContinueLearning(context),
                          SizedBox(height: 32.h),
                          _buildSectionHeader(
                            context,
                            'Recommended for You',
                            () {
                              controller.goToAllCourses();
                            },
                          ),
                          SizedBox(height: 16.h),
                          _buildRecommendations(context),
                          SizedBox(height: 32.h),
                          _buildStatsSection(context),
                          SizedBox(height: 100.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _renderTitle(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    if (hour >= 12 && hour < 17) greeting = 'Good Afternoon';
    if (hour >= 17) greeting = 'Good Evening';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => controller.goToProfile(),
            onLongPress: () => controller.changeProfilePicture(),
            child: Obx(() {
              final profilePic = controller.user.value.profilePic;
              return Stack(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: profilePic != null && profilePic.isNotEmpty
                        ? FileImage(File(profilePic)) as ImageProvider
                        : null,
                    child: profilePic == null || profilePic.isEmpty
                        ? Text(
                            (controller.user.value.name?.isNotEmpty ?? false)
                                ? controller.user.value.name![0].toUpperCase()
                                : 'U',
                            style: GoogleFonts.outfit(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => controller.changeProfilePicture(),
                      child: Container(
                        padding: EdgeInsets.all(2.r),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 10.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                greeting,
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Obx(
                () => Text(
                  controller.user.value.name ?? 'User',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.notifications_none_rounded,
              size: 24.sp,
              color: Colors.white,
            ),
            onPressed: () {
              HapticUtils.lightImpact();
              controller.goToNotifications();
            },
          ),
          // SizedBox(width: 8.w),
          // IconButton(
          //   icon: Icon(
          //     Icons.favorite_border_rounded,
          //     size: 24.sp,
          //     color: Colors.white,
          //   ),
          //   onPressed: () {
          //     // Get.to(() => FavouritesScreen()); // Add when available
          //   },
          // ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildHeaderCard(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(110.h),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        child: Obx(() {
          final courses = controller.enrolledCourses;
          if (courses.isEmpty) {
            return const StreakCelebrationCard(
              streak: 12,
              message: 'Start a course to begin your streak!',
              showCelebration: false,
            );
          }

          final course = courses.first;
          return Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.play_circle_fill_rounded,
                    color: AppColors.primary,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue Learning',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        course.title,
                        style: GoogleFonts.outfit(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: course.progress,
                          backgroundColor: Colors.grey[100],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                          minHeight: 4.h,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(30.r),
                  child: InkWell(
                    onTap: () => controller.openCourse(course),
                    borderRadius: BorderRadius.circular(30.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      child: Text(
                        'Resume',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    VoidCallback onSeeAll,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Text(
            'See All',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueLearning(BuildContext context) {
    return Obx(() {
      final courses = controller.enrolledCourses;
      if (courses.isEmpty) {
        return const SizedBox.shrink();
      }
      final course = courses.first;
      return LastActivityCard(
        courseTitle: course.title,
        topicTitle: 'Working with Variables',
        timeAgo: '2 hours ago',
        progress: course.progress,
        accentColor: _getLanguageColor(course.category),
        onTap: () => controller.openCourse(course),
      );
    });
  }

  Widget _buildRecommendations(BuildContext context) {
    return SizedBox(
      height: 200.h,
      child: Obx(() {
        final courses = controller.recommendedCourses;
        if (courses.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: courses.length,
          separatorBuilder: (_, __) => SizedBox(width: 16.w),
          itemBuilder: (context, index) {
            final course = courses[index];
            return _buildCourseCard(context, course);
          },
        );
      }),
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = _getLanguageColor(course.category);

    return AnimatedTapScale(
      onTap: () => controller.openCourse(course),
      child: Container(
        width: 280.w,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    course.category.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
                Icon(Icons.more_horiz_rounded, color: Colors.grey[400]),
              ],
            ),
            const Spacer(),
            Text(
              course.title,
              style: GoogleFonts.outfit(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.star_rounded, color: Colors.amber, size: 16.sp),
                SizedBox(width: 4.w),
                Text(
                  course.rating.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 12.w),
                Icon(
                  Icons.signal_cellular_alt_rounded,
                  color: Colors.grey,
                  size: 16.sp,
                ),
                SizedBox(width: 4.w),
                Text(course.level, style: GoogleFonts.inter(fontSize: 12.sp)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => controller.goToAnalyticsTab(),
            child: LevelProgressCard(
              currentLevel: controller.user.value.stats?.totalXP ?? 0,
              currentXP: 850,
              xpForNextLevel: 1000,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context,
            'Quick Practice',
            'Sharpen skills',
            Icons.fitness_center_rounded,
            const [Color(0xFF3B82F6), Color(0xFF2563EB)],
            () => controller.goToPractice(),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildActionCard(
            context,
            'My Insights',
            'View progress',
            Icons.analytics_rounded,
            const [Color(0xFF9333EA), Color(0xFF7C3AED)],
            () => controller.goToAnalytics(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    List<Color> colors,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedTapScale(
      onTap: () {
        HapticUtils.mediumImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: Colors.white, size: 20.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.inter(fontSize: 11.sp, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAISuggestion(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() {
      final rec = controller.recommendedTopic.value;
      if (rec == null) return const SizedBox.shrink();

      return AnimatedTapScale(
        onTap: () => controller.navigateToRecommendation(),
        child: Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                  : [const Color(0xFFF8FAFC), Colors.white],
            ),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI INSIGHT',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Retake ${rec.conceptName}',
                      style: GoogleFonts.outfit(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Focus on ${rec.subTopic} to improve mastery.',
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
                size: 16.sp,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      );
    });
  }

  Color _getLanguageColor(String title) {
    if (title.toLowerCase().contains('python')) return const Color(0xFF3B82F6);
    if (title.toLowerCase().contains('javascript'))
      return const Color(0xFFF59E0B);
    if (title.toLowerCase().contains('java')) return const Color(0xFFEF4444);
    if (title.toLowerCase().contains('c++')) return const Color(0xFFA855F7);
    if (title.toLowerCase().contains('go')) return const Color(0xFF06B6D4);
    if (title.toLowerCase().contains('typescript'))
      return const Color(0xFF60A5FA);
    return AppColors.primary;
  }
}

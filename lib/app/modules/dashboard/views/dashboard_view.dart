import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animated_widgets.dart';
import '../../../core/widgets/special_cards.dart';
import '../../../core/widgets/enhanced_navigation.dart';
import '../../../core/utils/haptic_utils.dart';
import '../controllers/dashboard_controller.dart';
import '../../../data/models/course_model.dart';
import '../../../routes/app_pages.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => controller.fetchData(),
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  _buildHeader(context),
                  SizedBox(height: 24.h),
                  _buildStreakCard(context),
                  SizedBox(height: 32.h),
                  _buildSectionHeader(context, 'Continue Learning', () {
                    Get.toNamed(Routes.myCourses);
                  }),
                  SizedBox(height: 16.h),
                  _buildContinueLearning(context),
                  SizedBox(height: 32.h),
                  _buildSectionHeader(context, 'Recommended for You', () {
                    Get.toNamed(Routes.courses);
                  }),
                  SizedBox(height: 16.h),
                  _buildRecommendations(context),
                  SizedBox(height: 32.h),
                  _buildStatsSection(context),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: AnimatedTapScale(
        onTap: () => _showCreatePathSheet(context),
        child: Container(
          width: 56.w,
          height: 56.w,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF2563EB)],
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: Icon(Icons.add_rounded, color: Colors.white, size: 28.sp),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    if (hour >= 12 && hour < 17) greeting = 'Good Afternoon';
    if (hour >= 17) greeting = 'Good Evening';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
            Text(
              'Mian Abdullah',
              style: GoogleFonts.outfit(
                fontSize: 28.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        AnimatedTapScale(
          onTap: () => Get.toNamed(Routes.profile),
          child: Container(
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: CircleAvatar(
              radius: 22.r,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                'MA',
                style: GoogleFonts.outfit(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard(BuildContext context) {
    return const StreakCelebrationCard(
      streak: 12,
      message: 'You\'re on fire! Keep it up for 3 more days to reach 15!',
      showCelebration: true,
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
      if (controller.enrolledCourses.isEmpty) {
        return const SizedBox.shrink();
      }
      final course = controller.enrolledCourses.first;
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
        if (controller.recommendedCourses.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: controller.recommendedCourses.length,
          separatorBuilder: (_, __) => SizedBox(width: 16.w),
          itemBuilder: (context, index) {
            final course = controller.recommendedCourses[index];
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
      onTap: () => Get.toNamed(Routes.courseDetails, arguments: course),
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
          child: LevelProgressCard(
            currentLevel: 12,
            currentXP: 850,
            xpForNextLevel: 1000,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  void _showCreatePathSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    HapticUtils.mediumImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32.r),
            topRight: Radius.circular(32.r),
          ),
        ),
        padding: EdgeInsets.all(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Create Learning Path',
              style: GoogleFonts.outfit(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Choose a language to start your journey',
              style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey),
            ),
            SizedBox(height: 32.h),
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  childAspectRatio: 1.5,
                ),
                itemCount: controller.languages.length,
                itemBuilder: (context, index) {
                  final lang = controller.languages[index];
                  return _buildLanguageOption(context, lang);
                },
              ),
            ),
            SizedBox(height: 16.h),
            LoadingButton(
              text: 'Generate Path',
              isFullWidth: true,
              onPressed: () {
                Get.back();
                ToastNotification.show(
                  context,
                  message: 'AI is generating your path...',
                  type: ToastType.info,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, Map<String, String> lang) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getLanguageColor(lang['name']!);

    return Obx(() {
      final isSelected = controller.selectedLanguage.value == lang['name'];
      return AnimatedTapScale(
        onTap: () {
          HapticUtils.selectionClick();
          controller.selectedLanguage.value = lang['name']!;
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected
                  ? color
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: isSelected ? 2 : 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(lang['icon']!, style: TextStyle(fontSize: 24.sp)),
              SizedBox(height: 8.h),
              Text(
                lang['name']!,
                style: GoogleFonts.outfit(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? color
                      : (isDark ? Colors.white : Colors.black),
                ),
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

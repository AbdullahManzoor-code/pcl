import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/my_courses_controller.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../routes/app_pages.dart';
import '../../../core/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyCoursesView extends GetView<MyCoursesController> {
  const MyCoursesView({super.key});

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
                padding: EdgeInsets.fromLTRB(24.r, 24.r, 24.r, 0),
                child: Column(
                  children: [
                    _buildStatsSection(context, isDark),
                    SizedBox(height: 32.h),
                    Row(
                      children: [
                        Icon(
                          Icons.auto_stories_rounded,
                          color: AppColors.primary,
                          size: 24.sp,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Active Paths',
                          style: GoogleFonts.outfit(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              sliver: _buildCourseListSliver(context, isDark),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 100.h)),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePathSheet(context),
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Create Learning',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 140.h,
      pinned: true,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: EdgeInsets.only(left: 24.w, bottom: 16.h),
        title: Text(
          'My Learnings',
          style: GoogleFonts.outfit(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.darkBg,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, bool isDark) {
    final courses = controller.enrolledCourses;
    final activePaths = courses.length;
    final totalProgress = courses.fold<int>(
      0,
      (sum, c) => sum + (c.progress * 100).toInt(),
    );
    final avgAccuracy = courses.isEmpty
        ? 0
        : (courses.fold<int>(0, (sum, c) => sum + c.accuracy) / courses.length)
              .round();

    return Row(
      children: [
        _buildStatCard(
          context,
          'Active',
          activePaths.toString(),
          Icons.auto_awesome_rounded,
          [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
        ),
        SizedBox(width: 12.w),
        _buildStatCard(
          context,
          'Progress',
          '${courses.isEmpty ? 0 : (totalProgress / courses.length).toInt()}%',
          Icons.bolt_rounded,
          [const Color(0xFF10B981), const Color(0xFF059669)],
        ),
        SizedBox(width: 12.w),
        _buildStatCard(
          context,
          'Accuracy',
          '$avgAccuracy%',
          Icons.verified_rounded,
          [const Color(0xFFF59E0B), const Color(0xFFD97706)],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    List<Color> colors,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: LinearGradient(
            colors: [colors[0].withOpacity(0.8), colors[1]],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 18.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(double value, Color bg, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: LinearProgressIndicator(
        value: value,
        backgroundColor: bg,
        valueColor: AlwaysStoppedAnimation(color),
        minHeight: 6.h,
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, dynamic course) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = course.progress ?? 0.0;

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: InkWell(
        onTap: () {
          HapticUtils.lightImpact();
          Get.toNamed(Routes.courseDetails, arguments: {'course': course});
        },
        borderRadius: BorderRadius.circular(24.r),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    padding: EdgeInsets.all(10.r),
                    child: Hero(
                      tag: 'course_icon_${course.id}',
                      child: Image.network(
                        course.image,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.code_rounded, color: AppColors.primary),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: GoogleFonts.outfit(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${course.topicsCompleted}/${course.totalTopics} Topics • ${course.level}',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '${course.accuracy}%',
                      style: GoogleFonts.outfit(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
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
                    'Progress',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              _buildProgressBar(
                progress,
                AppColors.primary.withOpacity(0.1),
                AppColors.primary,
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 14.sp,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Last activity: ${course.lastActivity}',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16.sp,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseListSliver(BuildContext context, bool isDark) {
    final courses = controller.enrolledCourses;

    if (courses.isEmpty && !controller.isLoading.value) {
      return SliverToBoxAdapter(child: _buildEmptyState(context));
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == courses.length) {
          return _buildCreateNewPathCard(context);
        }
        return _buildCourseCard(context, courses[index]);
      }, childCount: courses.length + 1),
    );
  }

  Widget _buildCreateNewPathCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showCreatePathSheet(context),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
            width: 2.w,
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF22C55E)],
                ),
                borderRadius: BorderRadius.circular(999.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    blurRadius: 10.r,
                    offset: Offset(0, 5.h),
                  ),
                ],
              ),
              child: Icon(Icons.add, color: Colors.white, size: 32.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              'Create New Path',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Start learning a new programming language',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF3B82F6)),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                'Add Learning Path',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            'No courses found',
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try creating a new path',
            style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey),
          ),
        ],
      ),
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
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
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
              style: GoogleFonts.inter(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Choose a language to start your journey',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
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
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isCreating.value
                      ? null
                      : () {
                          Get.back();
                          controller.createLearningPath();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: controller.isCreating.value
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Generate Path',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
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
      return GestureDetector(
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
                  : (isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0)),
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
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? color
                      : (isDark ? Colors.white : const Color(0xFF1E293B)),
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
    return const Color(0xFF2563EB);
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/course_details_controller.dart';
import '../../../core/widgets/next_components.dart';
import '../../../core/widgets/animated_widgets.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../core/theme/app_theme.dart';

class CourseDetailsView extends GetView<CourseDetailsController> {
  const CourseDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBg : AppColors.lightBg,
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final course = controller.course.value;
          if (course == null) {
            return const Center(child: Text('Course not found'));
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context, course, isDark),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDemoTestCard(context, course, isDark),
                      SizedBox(height: 32.h),
                      _buildCourseGuide(context, course, isDark),
                      SizedBox(height: 32.h),
                      _buildStatsGrid(context, course, crossAxisCount: 2),
                      SizedBox(height: 40.h),
                      Row(
                        children: [
                          Icon(
                            Icons.list_alt_rounded,
                            color: AppColors.primary,
                            size: 24.sp,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'Learning Journey',
                            style: GoogleFonts.outfit(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.darkBg,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      _buildTopicsList(context, isDark),
                      SizedBox(height: 100.h), // Space for FAB
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
      floatingActionButton: Obx(() {
        final course = controller.course.value;
        if (course == null) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: NextButton(
            text: course.isEnrolled ? 'Enrolled' : 'Enroll Now',
            onPressed: () {
              HapticUtils.heavyImpact();
              if (course.isEnrolled) {
                controller.continueLearning();
              } else {
                controller.enroll();
              }
            },
            icon: course.isEnrolled
                ? Icons.check_rounded
                : Icons.add_rounded,
            isFullWidth: true,
          ),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildCourseGuide(BuildContext context, dynamic course, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'AI Path Guide',
                style: GoogleFonts.outfit(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            course.description,
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.6,
            ),
          ),
          SizedBox(height: 20.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: [
              _buildGuideFeature(
                Icons.check_circle_outline_rounded,
                'Structured for ${course.level}',
              ),
              _buildGuideFeature(
                Icons.bolt_rounded,
                '${course.intensity} Pace',
              ),
              _buildGuideFeature(
                Icons.psychology_outlined,
                'AI Evaluation Ready',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuideFeature(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: AppColors.primary),
          SizedBox(width: 8.w),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, dynamic course, bool isDark) {
    return SliverAppBar(
      expandedHeight: 240.h,
      pinned: true,
      stretch: true,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                    AppColors.violet600.withOpacity(0.9),
                  ],
                ),
              ),
            ),
            // Pattern or Accent
            Positioned(
              right: -50.w,
              top: -50.h,
              child: Container(
                width: 200.w,
                height: 200.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          course.level.toString().toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          width: 4.w,
                          height: 4.w,
                          decoration: const BoxDecoration(
                            color: Colors.white70,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '${course.intensity} Intensity'.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    course.title,
                    style: GoogleFonts.outfit(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 18.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${course.rating} (${course.reviewCount})',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Icon(
                        Icons.category_rounded,
                        color: Colors.white70,
                        size: 18.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        course.category,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoTestCard(BuildContext context, dynamic course, bool isDark) {
    if (course.accuracy != 0) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(height: 32.h),
        Container(
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFACC15),
                Color(0xFFEA580C),
              ], // yellow-400 to orange-600
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEA580C).withOpacity(0.1),
                blurRadius: 20.r,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.help_center_rounded,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      'Ready to Benchmark?',
                      style: GoogleFonts.inter(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                'Complete a quick diagnostic test to unlock your personalized learning roadmap and skipped advanced topics.',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.1),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticUtils.mediumImpact();
                    controller.handleDemoTest();
                  },
                  icon: Icon(Icons.play_arrow_rounded, size: 22.sp),
                  label: Text(
                    'START DIAGNOSTIC ASSESSMENT',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFEA580C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    dynamic course, {
    required int crossAxisCount,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 16.0.w;
        final childAspectRatio = crossAxisCount == 1 ? 2.5 : 1.4;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
          children: [
            _buildStatCard(
              context,
              title: 'Total Topics',
              value: '${course.totalTopics}',
              subtitle: 'Across all subtopics',
              icon: Icons.book_outlined,
              colors: [const Color(0xFF3B82F6), const Color(0xFF4F46E5)],
            ),
            _buildStatCard(
              context,
              title: 'Completed',
              value: '${course.topicsCompleted}',
              subtitle: 'Topics completed',
              icon: Icons.check_circle_outline_rounded,
              colors: [const Color(0xFF22C55E), const Color(0xFF10B981)],
            ),
            _buildStatCard(
              context,
              title: 'Accuracy',
              value: '${course.accuracy}%',
              subtitle: 'Average across topics',
              icon: Icons.track_changes_outlined,
              colors: [const Color(0xFFA855F7), const Color(0xFFEC4899)],
            ),
            _buildStatCard(
              context,
              title: 'Last Activity',
              value: course.lastActivity ?? 'N/A',
              subtitle: 'Keep the streak going!',
              icon: Icons.access_time_rounded,
              colors: [const Color(0xFFF97316), const Color(0xFFDC2626)],
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopicsList(BuildContext context, bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.topics.length,
      itemBuilder: (context, index) {
        final topic = controller.topics[index];

        return Obx(() {
          final selected = controller.selectedTopicId.value == topic.id;
          return AnimatedTapScale(
            onTap: () {
              HapticUtils.selectionClick();
              if (topic.isLocked) {
                Get.snackbar(
                  'Locked',
                  'Complete previous tests to unlock this one.',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }
              if (controller.selectedTopicId.value == topic.id) {
                controller.selectedTopicId.value = null;
              } else {
                controller.selectedTopicId.value = topic.id;
              }
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: selected ? 2 : 1.5,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(20.r),
                    child: Row(
                      children: [
                        // Topic Icon/Index
                        Container(
                          width: 48.w,
                          height: 48.w,
                          decoration: BoxDecoration(
                            color: topic.completed
                                ? AppColors.success.withOpacity(0.1)
                                : topic.isLocked
                                    ? Colors.grey.withOpacity(0.1)
                                    : AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: topic.completed
                                ? Icon(
                                    Icons.check_rounded,
                                    color: AppColors.success,
                                    size: 24.sp,
                                  )
                                : topic.isLocked
                                    ? Icon(
                                        Icons.lock_outline_rounded,
                                        color: Colors.grey,
                                        size: 20.sp,
                                      )
                                    : Text(
                                        '${index + 1}',
                                        style: GoogleFonts.outfit(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.sp,
                                        ),
                                      ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                topic.name,
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.darkBg,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '${topic.subTopics.length} Lessons • ${topic.subTopics.length * 10} mins',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (topic.completed)
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
                              '${topic.accuracy}%',
                              style: GoogleFonts.outfit(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (selected) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: EdgeInsets.all(20.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Configuration',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSelectionChip(
                                  'Quiz Mode',
                                  Icons.quiz_rounded,
                                  true,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _buildSelectionChip(
                                  'Study Mode',
                                  Icons.menu_book_rounded,
                                  false,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          NextButton(
                            text: 'Launch Assessment',
                            onPressed: () {
                              HapticUtils.mediumImpact();
                              controller.startTest(
                                topic,
                                controller.numQuestions.value,
                              );
                            },
                            isFullWidth: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildSelectionChip(String label, IconData icon, bool active) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary.withOpacity(0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: active ? AppColors.primary : AppColors.lightBorder,
          width: active ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: active ? AppColors.primary : Colors.grey,
            size: 20.sp,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: active ? AppColors.primary : Colors.grey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.1),
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(icon, color: Colors.white, size: 14.sp),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 15.sp, // Bigger number
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  color: Colors.white.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

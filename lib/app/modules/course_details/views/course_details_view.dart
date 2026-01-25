import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/course_details_controller.dart';
import '../../../core/widgets/next_components.dart';
import '../../../core/utils/responsive_view.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../core/theme/app_theme.dart';

class CourseDetailsView extends GetView<CourseDetailsController> {
  const CourseDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Course Details')),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColors.darkBg, AppColors.darkSurface, AppColors.darkBg]
                : [
                    const Color(0xFFF8FAFC), // AppColors.lightBg
                    Colors.white,
                    const Color(0xFFF1F5F9), // AppColors.lightDivider
                  ],
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final course = controller.course.value;
            if (course == null) {
              return const Center(child: Text('Course not found'));
            }

            return ResponsiveView(
              mobile: _buildMobileLayout(context, course, isDark),
              desktop: _buildDesktopLayout(context, course, isDark),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, dynamic course, bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, course, isDark),
          _buildDemoTestCard(context, course, isDark),
          SizedBox(height: 32.h),
          _buildStatsGrid(context, course, crossAxisCount: 2),
          SizedBox(height: 32.h),
          Text(
            'Core Topics',
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 16.h),
          _buildTopicsList(context, isDark),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    dynamic course,
    bool isDark,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1200.w),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 32.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Course Info & Stats
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, course, isDark),
                    _buildDemoTestCard(context, course, isDark),
                    SizedBox(height: 32.h),
                    _buildStatsGrid(context, course, crossAxisCount: 2),
                  ],
                ),
              ),
              SizedBox(width: 48.w),
              // Right Column: Topics List
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Core Topics',
                      style: GoogleFonts.inter(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildTopicsList(context, isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic course, bool isDark) {
    final level = course.level.toString();
    Color badgeColor;
    Color badgeTextColor;
    if (level.contains("Beginner") || level.contains("Easy")) {
      badgeColor = isDark ? AppColors.successBgDark : AppColors.successBgLight;
      badgeTextColor = isDark
          ? AppColors.successTextDark
          : AppColors.successTextLight;
    } else if (level.contains("Intermediate") || level.contains("Medium")) {
      badgeColor = isDark
          ? const Color(0xFF713F12)
          : AppColors.accent.withOpacity(0.2);
      badgeTextColor = isDark ? AppColors.accent : const Color(0xFFA16207);
    } else {
      badgeColor = isDark ? AppColors.errorBgDark : AppColors.errorBgLight;
      badgeTextColor = isDark
          ? AppColors.errorTextDark
          : AppColors.errorTextLight;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFF2563EB), // Blue-600
                  Color(0xFF9333EA), // Purple-600
                  Color(0xFF2563EB), // Blue-600
                ],
              ).createShader(bounds),
              child: Text(
                course.title,
                style: GoogleFonts.inter(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                course.level,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: badgeTextColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          'Track your progress and practice with MCQs',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
          ),
        ),
      ],
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
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.topics.length,
      separatorBuilder: (context, index) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final topic = controller.topics[index];

        return Obx(() {
          final selected = controller.selectedTopicId.value == topic.id;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: selected
                    ? const Color(0xFF3B82F6)
                    : (isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0)),
                width: selected ? 2.w : 1.w,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        blurRadius: 10.r,
                        offset: Offset(0, 5.h),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    HapticUtils.selectionClick();
                    if (controller.selectedTopicId.value == topic.id) {
                      controller.selectedTopicId.value = null;
                    } else {
                      controller.selectedTopicId.value = topic.id;
                    }
                  },
                  borderRadius: BorderRadius.circular(8.r),
                  child: Padding(
                    padding: EdgeInsets.all(20.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      topic.name,
                                      style: GoogleFonts.inter(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  if (topic.completed)
                                    Padding(
                                      padding: EdgeInsets.only(left: 8.w),
                                      child: Icon(
                                        Icons.check_circle_rounded,
                                        color: const Color(0xFF22C55E),
                                        size: 20.sp,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (topic.completed)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Accuracy',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                  Text(
                                    '${topic.accuracy}%',
                                    style: GoogleFonts.inter(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF22C55E),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '${topic.subTopics.length} subtopics',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: topic.subTopics
                              .take(3)
                              .map(
                                (sub) => Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(999.r),
                                  ),
                                  child: Text(
                                    sub.title,
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      color: isDark
                                          ? const Color(0xFFCBD5E1)
                                          : const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                if (selected)
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                    padding: EdgeInsets.all(20.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Number of MCQs',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          height: 48.h,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFCBD5E1),
                            ),
                            borderRadius: BorderRadius.circular(6.r),
                            color: isDark
                                ? const Color(0xFF0F172A)
                                : Colors.white,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: controller.numQuestions.value
                                      .toString(),
                                  keyboardType: TextInputType.number,
                                  style: GoogleFonts.inter(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (val) {
                                    final n = int.tryParse(val);
                                    if (n != null)
                                      controller.numQuestions.value = n;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        SizedBox(
                          width: double.infinity,
                          child: NextButton(
                            text: 'Start Test',
                            onPressed: () {
                              HapticUtils.mediumImpact();
                              controller.startTest(
                                topic,
                                controller.numQuestions.value,
                              );
                            },
                            outline: true,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                    child: SizedBox(
                      width: double.infinity,
                      child: NextButton(
                        text: 'Practice This Topic',
                        onPressed: () {
                          HapticUtils.lightImpact();
                          controller.selectedTopicId.value = topic.id;
                        },
                        outline: true,
                      ),
                    ),
                  ),
              ],
            ),
          );
        });
      },
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

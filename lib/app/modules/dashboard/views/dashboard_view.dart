import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/next_components.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/utils/responsive_view.dart';
import '../controllers/dashboard_controller.dart';
import '../../../data/models/course_model.dart';
import '../../../routes/app_pages.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => controller.fetchData(),
          child: ResponsiveView(
            mobile: _buildMobileLayout(context),
            desktop: _buildDesktopLayout(context),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              SizedBox(height: 24.h),
              const StatsCardSkeleton(),
              const StatsCardSkeleton(),
              const CourseCardSkeleton(),
              const CourseCardSkeleton(),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(context),
            SizedBox(height: 24.h),
            _buildAIRecommendation(context),
            SizedBox(height: 32.h),
            _buildQuickActions(context),
            SizedBox(height: 32.h),
            _buildStatsGrid(context, crossAxisCount: 2),
            SizedBox(height: 32.h),
            _buildMyLearningPaths(context),
            SizedBox(height: 32.h),
            _buildCreatePathSection(context),
            SizedBox(height: 80.h),
          ],
        ),
      );
    });
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 32.h),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1200.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(context),
              SizedBox(height: 32.h),
              _buildAIRecommendation(context),
              SizedBox(height: 32.h),
              _buildStatsGrid(context, crossAxisCount: 4),
              SizedBox(height: 48.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildMyLearningPaths(context)),
                  SizedBox(width: 32.w),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        _buildCreatePathSection(context),
                        // Add more side widgets here if needed
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 80.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIRecommendation(BuildContext context) {
    return Obx(() {
      if (controller.recommendedTopic.value == null)
        return const SizedBox.shrink();

      final rec = controller.recommendedTopic.value!;
      final diffInfo = _getDifficultyInfo(rec.targetDifficulty);

      return Container(
        margin: EdgeInsets.only(bottom: 24.h),
        child: Container(
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.1),
                Colors.green.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.amber, Colors.orange],
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'AI RECOMMENDED FOR YOU',
                    style: GoogleFonts.outfit(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: diffInfo.colors),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      diffInfo.label,
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Text(
                rec.conceptName,
                style: GoogleFonts.outfit(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                rec.subTopic,
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  _buildRecStat(
                    Icons.timer_rounded,
                    '${rec.estimatedTimeMinutes} min',
                    Colors.blue,
                  ),
                  SizedBox(width: 16.w),
                  _buildRecStat(
                    Icons.trending_up_rounded,
                    '${(rec.targetDifficulty * 100).round()}%',
                    Colors.green,
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Why this topic?',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      rec.reason,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              NextButton(
                text: 'Start Practice Now',
                onPressed: () => controller.navigateToRecommendation(),
                isFullWidth: true,
                icon: Icons.play_arrow_rounded,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildRecStat(IconData icon, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: color, size: 16.sp),
        ),
        SizedBox(width: 8.w),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  _DifficultyInfo _getDifficultyInfo(double difficulty) {
    if (difficulty < 0.4) {
      return _DifficultyInfo('Beginner', [Colors.green, Colors.greenAccent]);
    } else if (difficulty < 0.7) {
      return _DifficultyInfo('Intermediate', [Colors.orange, Colors.amber]);
    } else {
      return _DifficultyInfo('Advanced', [Colors.red, Colors.pinkAccent]);
    }
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              AppColors.indigo600,
              AppColors.secondary,
              AppColors.indigo600,
            ],
          ).createShader(bounds),
          child: Text(
            'Welcome to LearnRL! 👋',
            style: GoogleFonts.inter(
              fontSize: 28.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white, // Required for ShaderMask
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Create your personalized learning path and start mastering programming',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, {int crossAxisCount = 2}) {
    return Obx(() {
      final activePaths = controller.enrolledCourses.length;
      final totalTopics = controller.enrolledCourses.fold(
        0,
        (sum, c) => sum + c.topicsCompleted,
      );

      // Calculate avg accuracy safely
      int avgAccuracy = 0;
      if (controller.enrolledCourses.isNotEmpty) {
        final totalAcc = controller.enrolledCourses.fold(
          0,
          (sum, c) => sum + c.accuracy,
        );
        avgAccuracy = (totalAcc / controller.enrolledCourses.length).round();
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          final spacing = 16.0.w;
          final totalSpacing = spacing * (crossAxisCount - 1);
          final itemWidth =
              (constraints.maxWidth - totalSpacing) / crossAxisCount;

          final uniqueLanguages = controller.enrolledCourses
              .map((c) => c.category)
              .toSet()
              .length;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              _buildStatCard(
                context,
                'Active Paths',
                activePaths.toString(),
                Icons.book,
                Colors.blue,
                itemWidth,
              ),
              _buildStatCard(
                context,
                'Total Topics',
                totalTopics.toString(),
                Icons.code,
                Colors.green,
                itemWidth,
              ),
              _buildStatCard(
                context,
                'Avg Accuracy',
                '$avgAccuracy%',
                Icons.trending_up,
                Colors.orange,
                itemWidth,
              ),
              _buildStatCard(
                context,
                'Languages',
                uniqueLanguages.toString(),
                Icons.play_arrow,
                Colors.purple,
                itemWidth,
              ),
            ],
          );
        },
      );
    });
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context,
            'Practice',
            'Try random quizzes',
            Icons.fitness_center_rounded,
            const [Color(0xFF8B5CF6), Color(0xFFC026D3)],
            () => Get.toNamed(Routes.practice),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildActionCard(
            context,
            'Analytics',
            'Track your progress',
            Icons.analytics_rounded,
            const [Color(0xFF3B82F6), Color(0xFF2DD4BF)],
            () => Get.toNamed(Routes.analytics),
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
    List<Color> gradient,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NextCard(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: Colors.white, size: 24.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: isDark ? Colors.white60 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    MaterialColor color,
    double width,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? color.shade900 : color.shade100,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withOpacity(0.1), Colors.transparent],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50.r),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.shade400, color.shade600],
                        ),
                        borderRadius: BorderRadius.circular(6.r),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.1),
                            blurRadius: 4.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 14.sp),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                    color: color.shade500, // Text color matches theme color
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyLearningPaths(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Learning Paths',
          style: GoogleFonts.inter(
            fontSize: 24.sp,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: 16.h),
        Obx(() {
          if (controller.enrolledCourses.isEmpty) {
            return EmptyStateWidget(
              title: 'No Learning Paths Yet',
              message:
                  'Create your first learning path to start your programming journey!',
              icon: Icons.school_outlined,
              actionText: 'Create Learning Path',
              onActionPressed: () {
                // Scroll to create section or show dialog
              },
            );
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.enrolledCourses.length,
            separatorBuilder: (_, __) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              final course = controller.enrolledCourses[index];
              return _buildLearningCard(context, course);
            },
          );
        }),
      ],
    );
  }

  Widget _buildLearningCard(BuildContext context, Course course) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine level color
    Color levelColor;
    String levelText = course.level; // "Medium", "Hard", etc.
    if (levelText.toLowerCase().contains('easy')) {
      levelColor = Colors.green;
    } else if (levelText.toLowerCase().contains('medium')) {
      levelColor = Colors.amber;
    } else {
      levelColor = Colors.red;
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkSurface : AppColors.lightBorder,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Colors.blue.withOpacity(0.1), Colors.transparent],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50.r),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Image/Icon Placeholder
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          // If real image exists use it, else icon
                          child:
                              course.image.isNotEmpty &&
                                  !course.image.startsWith('assets')
                              ? Image.network(
                                  course.image,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.code),
                                )
                              : const Icon(Icons.code, color: Colors.black87),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          course.title,
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    NextBadge(text: levelText, color: levelColor),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  '${course.topicsCompleted} / ${course.totalTopics} topics completed',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                SizedBox(height: 20.h),

                // Progress Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    Text(
                      '${(course.progress * 100).toInt()}%',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999.r),
                  child: LinearProgressIndicator(
                    value: course.progress,
                    minHeight: 8.h,
                    backgroundColor: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Accuracy and Button
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.green.shade900.withOpacity(0.1)
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Accuracy',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${course.accuracy}%',
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                NextButton(
                  text: 'Open Learning Dashboard',
                  onPressed: () => controller.openCourse(course),
                  isFullWidth: true,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePathSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NextCard(
      padding: EdgeInsets.all(24.r),
      showShadow: true,
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: const Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFF3B82F6),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create New Learning Path',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      'Select a language and difficulty to start',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Language Selection
          Text(
            'Language',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: controller.languages.map((lang) {
              return Obx(() {
                final isSelected =
                    controller.selectedLanguage.value == lang['name'];
                return InkWell(
                  onTap: () =>
                      controller.selectedLanguage.value = lang['name']!,
                  borderRadius: BorderRadius.circular(8.r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : (isDark
                                ? AppColors.darkSurface
                                : AppColors.lightBorder),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                        width: isSelected ? 2.w : 1.w,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(lang['icon']!, style: TextStyle(fontSize: 18.sp)),
                        SizedBox(width: 8.w),
                        Text(
                          lang['name']!,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : (isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            }).toList(),
          ),

          SizedBox(height: 24.h),

          // Difficulty Selection
          Text(
            'Difficulty',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 12.w,
            children: controller.difficulties.map((diff) {
              return Obx(() {
                final isSelected = controller.selectedDifficulty.value == diff;
                Color activeColor;
                switch (diff) {
                  case 'Easy':
                    activeColor = AppColors.secondary;
                    break;
                  case 'Medium':
                    activeColor = AppColors.warning;
                    break;
                  case 'Hard':
                    activeColor = AppColors.error;
                    break;
                  default:
                    activeColor = AppColors.primary; // Fallback
                }

                return InkWell(
                  onTap: () => controller.selectedDifficulty.value = diff,
                  borderRadius: BorderRadius.circular(999.r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? activeColor.withOpacity(0.1)
                          : (isDark
                                ? const Color(0xFF0F172A)
                                : const Color(0xFFF1F5F9)),
                      border: Border.all(
                        color: isSelected
                            ? activeColor
                            : (isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0)),
                        width: isSelected ? 2.w : 1.w,
                      ),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text(
                      diff,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected
                            ? activeColor
                            : (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary),
                      ),
                    ),
                  ),
                );
              });
            }).toList(),
          ),

          SizedBox(height: 32.h),

          // Create Button
          SizedBox(
            width: double.infinity,
            child: Obx(
              () => NextButton(
                text: controller.isCreating.value
                    ? 'Creating...'
                    : 'Create Learning Path',
                onPressed: controller.isCreating.value
                    ? () {}
                    : controller.createLearningPath,
                color: AppColors.indigo600,
                icon: controller.isCreating.value
                    ? null
                    : Icons.arrow_forward_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyInfo {
  final String label;
  final List<Color> colors;
  _DifficultyInfo(this.label, this.colors);
}

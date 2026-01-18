import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/my_courses_controller.dart';
import '../../../core/widgets/next_components.dart';
import '../../../core/utils/responsive_view.dart';
import '../../../routes/app_pages.dart';

class MyCoursesView extends GetView<MyCoursesController> {
  const MyCoursesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0F172A),
                    const Color(0xFF1E293B),
                    const Color(0xFF0F172A),
                  ]
                : [
                    const Color(0xFFEFFDF5),
                    Colors.white,
                    const Color(0xFFEFF6FF),
                  ],
          ),
        ),
        child: SafeArea(
          child: ResponsiveView(
            mobile: _buildMobileLayout(context),
            desktop: _buildDesktopLayout(context),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 32),
          _buildStatsGrid(context, crossAxisCount: 1),
          const SizedBox(height: 32),
          _buildCourseList(context, isGrid: false),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 32),
              _buildStatsGrid(context, crossAxisCount: 3),
              const SizedBox(height: 48),
              _buildCourseList(context, isGrid: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF16A34A), // Green-600
              Color(0xFF2563EB), // Blue-600
            ],
          ).createShader(bounds),
          child: Text(
            'My Learnings',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Track and continue your active learning paths',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
          ),
        ),
      ],
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.1),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, course) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = course.progress ?? 0.0;

    // Determine badge color based on level
    final level = course.level.toString(); // e.g. "Beginner" -> Easy
    Color badgeColor;
    Color badgeTextColor;

    if (level.contains("Beginner") || level.contains("Easy")) {
      badgeColor = isDark
          ? const Color(0xFF14532D)
          : const Color(0xFFDCFCE7); // Green-900/100
      badgeTextColor = isDark
          ? const Color(0xFFDCFCE7)
          : const Color(0xFF15803D); // Green-100/700
    } else if (level.contains("Intermediate") || level.contains("Medium")) {
      badgeColor = isDark
          ? const Color(0xFF713F12)
          : const Color(0xFFFEF9C3); // Yellow-900/100
      badgeTextColor = isDark
          ? const Color(0xFFFEF9C3)
          : const Color(0xFFA16207); // Yellow-100/700
    } else {
      badgeColor = isDark
          ? const Color(0xFF7F1D1D)
          : const Color(0xFFFEE2E2); // Red-900/100
      badgeTextColor = isDark
          ? const Color(0xFFFEE2E2)
          : const Color(0xFFB91C1C); // Red-100/700
    }

    return NextCard(
      onTap: () =>
          Get.toNamed(Routes.courseDetails, arguments: {'course': course}),
      padding: const EdgeInsets.all(24),
      showShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                course.title,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  course.level,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Last activity: ${course.lastActivity}',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF3B82F6)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Topics',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${course.topicsCompleted}/${course.totalTopics}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Accuracy',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${course.accuracy}%',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22C55E), // Green-500
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: NextButton(
              text: 'Continue Learning',
              onPressed: () => Get.toNamed(
                Routes.courseDetails,
                arguments: {'course': course},
              ),
              color: const Color(0xFF2563EB),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, {int crossAxisCount = 3}) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final courses = controller.enrolledCourses;
      final activePaths = courses.length;
      final totalProgress = courses.fold<int>(
        0,
        (sum, item) => sum + item.topicsCompleted,
      );
      final avgAccuracy = activePaths > 0
          ? (courses.fold<int>(0, (sum, item) => sum + item.accuracy) /
                    activePaths)
                .round()
          : 0;

      return LayoutBuilder(
        builder: (context, constraints) {
          final spacing = 12.0;
          // final totalSpacing = spacing * (crossAxisCount - 1);
          // final itemWidth = (constraints.maxWidth - totalSpacing) / crossAxisCount;
          final aspectRatio = crossAxisCount == 1 ? 2.5 : 0.85;

          return GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: aspectRatio,
            children: [
              _buildStatCard(
                context,
                title: 'Active Paths',
                value: '$activePaths',
                subtitle:
                    'Across ${courses.map((e) => e.title).toSet().length} languages',
                icon: Icons.book_outlined,
                colors: [const Color(0xFF22C55E), const Color(0xFF10B981)],
              ),
              _buildStatCard(
                context,
                title: 'Total Progress',
                value: '$totalProgress',
                subtitle: 'Topics completed',
                icon: Icons.trending_up_rounded,
                colors: [const Color(0xFF3B82F6), const Color(0xFF6366F1)],
              ),
              _buildStatCard(
                context,
                title: 'Avg Accuracy',
                value: '$avgAccuracy%',
                subtitle: 'Across all paths',
                icon: Icons.check_circle_outline_rounded,
                colors: [const Color(0xFFA855F7), const Color(0xFFEC4899)],
              ),
            ],
          );
        },
      );
    });
  }

  Widget _buildCourseList(BuildContext context, {required bool isGrid}) {
    return Obx(() {
      if (controller.enrolledCourses.isEmpty && !controller.isLoading.value) {
        return _buildEmptyState(context);
      }

      final itemCount = controller.enrolledCourses.length + 1;

      if (isGrid) {
        return Wrap(
          spacing: 24,
          runSpacing: 24,
          children: List.generate(itemCount, (index) {
            return SizedBox(
              width: 350,
              child: index == controller.enrolledCourses.length
                  ? _buildCreateNewPathCard(context)
                  : _buildCourseCard(
                      context,
                      controller.enrolledCourses[index],
                    ),
            );
          }),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (context, index) => const SizedBox(height: 24),
        itemBuilder: (context, index) {
          if (index == controller.enrolledCourses.length) {
            return _buildCreateNewPathCard(context);
          }
          return _buildCourseCard(context, controller.enrolledCourses[index]);
        },
      );
    });
  }

  Widget _buildCreateNewPathCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Get.snackbar(
          "Coming Soon",
          "Create Path feature is not yet implemented in mock.",
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
            width: 2,
            style: BorderStyle
                .solid, // Dash support depends on package, using solid for now or CustomPainter
          ),
          // To simulate dash effect effectively we need mock or package. Solid border is acceptable fallback.
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
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              'Create New Path',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start learning a new programming language',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF3B82F6)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Add Learning Path',
                style: GoogleFonts.inter(
                  fontSize: 14,
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
    return Center(child: Text("No courses found"));
  }
}

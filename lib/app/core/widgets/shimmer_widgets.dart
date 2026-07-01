import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ─────────────────────────────────────────────────────────────
//  Base building block
// ─────────────────────────────────────────────────────────────
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2A2A3A) : const Color(0xFFE0E0E0),
      highlightColor: isDark
          ? const Color(0xFF3C3C52)
          : const Color(0xFFF5F5F5),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A3A) : Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Practice Screen shimmer
// ─────────────────────────────────────────────────────────────
class PracticeShimmer extends StatelessWidget {
  const PracticeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          // Info card
          ShimmerBox(width: double.infinity, height: 90.h, borderRadius: 24),
          SizedBox(height: 24.h),
          // Section header
          ShimmerBox(width: 160.w, height: 20.h),
          SizedBox(height: 16.h),
          // Dropdown
          ShimmerBox(width: double.infinity, height: 56.h, borderRadius: 20),
          SizedBox(height: 32.h),
          // Difficulty section header
          ShimmerBox(width: 180.w, height: 20.h),
          SizedBox(height: 16.h),
          ShimmerBox(width: double.infinity, height: 110.h, borderRadius: 24),
          SizedBox(height: 32.h),
          // Question count header
          ShimmerBox(width: 160.w, height: 20.h),
          SizedBox(height: 16.h),
          Row(
            children: List.generate(
              4,
              (i) => Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: ShimmerBox(width: 70.w, height: 38.h, borderRadius: 20),
              ),
            ),
          ),
          SizedBox(height: 32.h),
          // Mode section header
          ShimmerBox(width: 140.w, height: 20.h),
          SizedBox(height: 16.h),
          ...List.generate(
            3,
            (_) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: ShimmerBox(
                width: double.infinity,
                height: 80.h,
                borderRadius: 20,
              ),
            ),
          ),
          SizedBox(height: 32.h),
          // Start button
          ShimmerBox(width: double.infinity, height: 56.h, borderRadius: 16),
          SizedBox(height: 48.h),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Analytics (My Insights) shimmer
// ─────────────────────────────────────────────────────────────
class AnalyticsShimmer extends StatelessWidget {
  const AnalyticsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          // Stats 2x2 grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.1,
            children: List.generate(
              4,
              (_) => ShimmerBox(
                width: double.infinity,
                height: double.infinity,
                borderRadius: 20,
              ),
            ),
          ),
          SizedBox(height: 32.h),
          ShimmerBox(width: 180.w, height: 20.h),
          SizedBox(height: 16.h),
          ...List.generate(
            3,
            (_) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: ShimmerBox(
                width: double.infinity,
                height: 90.h,
                borderRadius: 16,
              ),
            ),
          ),
          SizedBox(height: 32.h),
          ShimmerBox(width: 160.w, height: 20.h),
          SizedBox(height: 16.h),
          ...List.generate(
            3,
            (_) => Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      ShimmerBox(width: 24.w, height: 24.h, borderRadius: 12),
                      SizedBox(height: 4.h),
                      ShimmerBox(width: 2.w, height: 80.h, borderRadius: 2),
                    ],
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ShimmerBox(
                      width: double.infinity,
                      height: 110.h,
                      borderRadius: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 80.h),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Course Details shimmer
// ─────────────────────────────────────────────────────────────
class CourseDetailsShimmer extends StatelessWidget {
  const CourseDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        // Sliver app bar placeholder
        SliverToBoxAdapter(
          child: ShimmerBox(
            width: double.infinity,
            height: 240.h,
            borderRadius: 0,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 32.h),
                // Demo card
                ShimmerBox(
                  width: double.infinity,
                  height: 160.h,
                  borderRadius: 16,
                ),
                SizedBox(height: 32.h),
                // AI Path Guide
                ShimmerBox(
                  width: double.infinity,
                  height: 130.h,
                  borderRadius: 24,
                ),
                SizedBox(height: 32.h),
                // Stats grid 2x2
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  childAspectRatio: 1.4,
                  children: List.generate(
                    4,
                    (_) => ShimmerBox(
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: 12,
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
                ShimmerBox(width: 200.w, height: 24.h),
                SizedBox(height: 16.h),
                ...List.generate(
                  4,
                  (_) => Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: ShimmerBox(
                      width: double.infinity,
                      height: 88.h,
                      borderRadius: 24,
                    ),
                  ),
                ),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Courses list shimmer (CoursesView)
// ─────────────────────────────────────────────────────────────
class CoursesListShimmer extends StatelessWidget {
  const CoursesListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 40.h),
      itemCount: 6,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (_, __) =>
          ShimmerBox(width: double.infinity, height: 90.h, borderRadius: 20),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  My Courses (My Learning tab) shimmer
// ─────────────────────────────────────────────────────────────
class MyCoursesShimmer extends StatelessWidget {
  const MyCoursesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: 140.h)),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.r, 24.r, 24.r, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats row
                Row(
                  children: List.generate(
                    3,
                    (i) => [
                      Expanded(
                        child: ShimmerBox(
                          width: double.infinity,
                          height: 100.h,
                          borderRadius: 20,
                        ),
                      ),
                      if (i < 2) SizedBox(width: 12.w),
                    ],
                  ).expand((e) => e).toList(),
                ),
                SizedBox(height: 32.h),
                ShimmerBox(width: 140.w, height: 24.h),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, __) => Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: ShimmerBox(
                  width: double.infinity,
                  height: 140.h,
                  borderRadius: 24,
                ),
              ),
              childCount: 4,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Dashboard recommendations shimmer (horizontal list)
// ─────────────────────────────────────────────────────────────
class RecommendationsShimmer extends StatelessWidget {
  const RecommendationsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        separatorBuilder: (_, __) => SizedBox(width: 16.w),
        itemBuilder: (_, __) =>
            ShimmerBox(width: 280.w, height: 200.h, borderRadius: 24),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Learning view shimmer (content + quiz layout)
// ─────────────────────────────────────────────────────────────
class LearningShimmer extends StatelessWidget {
  const LearningShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner placeholder
                  ShimmerBox(
                    width: double.infinity,
                    height: 200.h,
                    borderRadius: 16,
                  ),
                  SizedBox(height: 24.h),
                  // Content lines
                  ...List.generate(
                    6,
                    (i) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: ShimmerBox(
                        width: i % 3 == 2 ? 220.w : double.infinity,
                        height: 16.h,
                        borderRadius: 8,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // Code block placeholder
                  ShimmerBox(
                    width: double.infinity,
                    height: 120.h,
                    borderRadius: 12,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // Button
          ShimmerBox(width: double.infinity, height: 56.h, borderRadius: 12),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Profile view shimmer
// ─────────────────────────────────────────────────────────────
class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header placeholder matching profile header
          ShimmerBox(
            width: double.infinity,
            height: 240.h,
            borderRadius: 0,
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Title: Knowledge Decay
                ShimmerBox(width: 180.w, height: 20.h),
                SizedBox(height: 16.h),
                // Knowledge Decay card placeholder
                ShimmerBox(
                  width: double.infinity,
                  height: 120.h,
                  borderRadius: 24,
                ),
                SizedBox(height: 32.h),

                // Section Title: Recent Sessions
                ShimmerBox(width: 140.w, height: 20.h),
                SizedBox(height: 16.h),
                // Recent sessions items
                ...List.generate(
                  2,
                  (_) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: ShimmerBox(
                      width: double.infinity,
                      height: 80.h,
                      borderRadius: 20,
                    ),
                  ),
                ),
                SizedBox(height: 32.h),

                // Section Title: Topic Mastery
                ShimmerBox(width: 160.w, height: 20.h),
                SizedBox(height: 16.h),
                // Topic Mastery items
                ...List.generate(
                  3,
                  (_) => Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: ShimmerBox(
                      width: double.infinity,
                      height: 70.h,
                      borderRadius: 16,
                    ),
                  ),
                ),
                SizedBox(height: 80.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


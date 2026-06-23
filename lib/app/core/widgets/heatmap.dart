import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:pcl/app/data/models/dashboard_api_models.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class LearningHeatmap extends StatelessWidget {
  final Map<String, HeatmapDay> data;
  final RxString selectedFilter; // 'week' | 'month' | '6m' | 'year'
  final bool isLoading;

  const LearningHeatmap({
    super.key,
    required this.data,
    required this.selectedFilter,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final filter = selectedFilter.value;
      int days;
      switch (filter) {
        case 'week':
          days = 7;
          break;
        case 'month':
          days = 30;
          break;
        case '6m':
          days = 180;
          break;
        case 'year':
        default:
          days = 365;
          break;
      }

      return Container(
        padding: EdgeInsets.all(20.r),
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
                Expanded(
                  child: Text(
                    'Activity Heatmap',
                    style: GoogleFonts.outfit(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _buildFilterTabs(isDark),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            SizedBox(
              height: 140.h,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Estimate number of columns (weeks)
                  final int columns = (days / 7).ceil() + 1;
                  final double margin = 2.r;

                  // Calculate size to fit horizontally and vertically
                  double sizeByWidth = (constraints.maxWidth / columns) - (margin * 2);
                  double sizeByHeight = (constraints.maxHeight / 7) - (margin * 2);

                  // Keep it a PERFECT SQUARE, constrained by both dimensions.
                  // Min size: 12.w (so year view is readable and scrolls).
                  double squareSize = math.max(math.min(sizeByWidth, sizeByHeight), 12.w);

                  final grid = isLoading
                      ? _buildSkeleton(isDark, days, squareSize, margin)
                      : _buildHeatmapGrid(isDark, days, squareSize, margin);

                  return Center(
                    child: grid,
                  );
                },
              ),
            ),
            SizedBox(height: 16.h),
            if (!isLoading) _buildStatsStrip(isDark, days),
          ],
        ),
      );
    });
  }

  Widget _buildFilterTabs(bool isDark) {
    return Row(
      children: [
        // _buildFilterPill('Week', 'week', isDark),
        _buildFilterPill('Month', 'month', isDark),
        // _buildFilterPill('6M', '6m', isDark),
        _buildFilterPill('Year', 'year', isDark),
      ],
    );
  }

  Widget _buildFilterPill(String label, String value, bool isDark) {
    final isSelected = selectedFilter.value == value;
    return GestureDetector(
      onTap: () => selectedFilter.value = value,
      child: Container(
        margin: EdgeInsets.only(left: 4.w),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
          ),
        ),
      ),
    );
  }

  Widget _buildHeatmapGrid(
    bool isDark,
    int days,
    double squareSize,
    double margin,
  ) {
    final now = DateTime.now();
    final List<DateTime> dates = List.generate(
      days,
      (i) => now.subtract(Duration(days: days - 1 - i)),
    );

    final List<List<DateTime>> weeks = [];
    List<DateTime> currentWeek = [];

    for (var date in dates) {
      currentWeek.add(date);
      if (date.weekday == DateTime.sunday || date == dates.last) {
        weeks.add(currentWeek);
        currentWeek = [];
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true, // Auto-scroll to the right (most recent)
      physics: const BouncingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: weeks
            .map((week) => _buildWeekColumn(week, isDark, squareSize, margin))
            .toList(),
      ),
    );
  }

  Widget _buildWeekColumn(
    List<DateTime> week,
    bool isDark,
    double squareSize,
    double margin,
  ) {
    final List<Widget> dayWidgets = [];

    if (week.length < 7 && week.first.weekday != DateTime.monday) {
      for (int i = 0; i < week.first.weekday - 1; i++) {
        dayWidgets.add(_buildDaySquare(null, isDark, squareSize, margin));
      }
    }

    for (var date in week) {
      dayWidgets.add(_buildDaySquare(date, isDark, squareSize, margin));
    }

    return Column(children: dayWidgets);
  }

  Widget _buildDaySquare(
    DateTime? date,
    bool isDark,
    double squareSize,
    double margin,
  ) {
    if (date == null) {
      return Container(
        width: squareSize,
        height: squareSize,
        margin: EdgeInsets.all(margin),
        color: Colors.transparent,
      );
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final heatmapDay = data[dateStr];

    Color color;
    if (heatmapDay == null || heatmapDay.sessionCount == 0) {
      color = isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100;
    } else {
      final score = heatmapDay.avgScore; // Accuracy is 0-100
      final intensity = (heatmapDay.sessionCount / 3).clamp(
        0.4,
        1.0,
      ); // Brighter for more sessions

      if (score < 50) {
        color = Colors.red.withOpacity(intensity);
      } else if (score < 75) {
        color = Colors.amber.withOpacity(intensity);
      } else {
        color = AppColors.primary.withOpacity(intensity);
      }
    }

    String tooltipMsg = DateFormat('MMM d').format(date);
    if (heatmapDay != null && heatmapDay.sessionCount > 0) {
      tooltipMsg +=
          ': ${heatmapDay.sessionCount} sessions · ${heatmapDay.avgScore.toStringAsFixed(0)}% avg';
    } else {
      tooltipMsg += ': No activity';
    }

    return Tooltip(
      message: tooltipMsg,
      child: Container(
        width: squareSize,
        height: squareSize,
        margin: EdgeInsets.all(margin),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  Widget _buildSkeleton(
    bool isDark,
    int days,
    double squareSize,
    double margin,
  ) {
    final List<DateTime> dates = List.generate(days, (i) => DateTime.now());
    final List<List<DateTime>> weeks = [];
    List<DateTime> currentWeek = [];

    for (var date in dates) {
      currentWeek.add(date);
      if (currentWeek.length == 7 || date == dates.last) {
        weeks.add(currentWeek);
        currentWeek = [];
      }
    }

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[300]!,
      highlightColor: isDark
          ? Colors.white.withOpacity(0.1)
          : Colors.grey[100]!,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: weeks.map((week) {
            return Column(
              children: week.map((_) {
                return Container(
                  width: squareSize,
                  height: squareSize,
                  margin: EdgeInsets.all(margin),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatsStrip(bool isDark, int days) {
    final now = DateTime.now();
    int activeDays = 0;
    double totalScore = 0;
    int currentStreak = 0;

    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final heatmapDay = data[dateStr];

      if (heatmapDay != null && heatmapDay.sessionCount > 0) {
        activeDays++;
        totalScore += heatmapDay.avgScore;
        if (i == currentStreak || i == currentStreak + 1) {
          // Allow skipping today if not practiced yet
          if (i == currentStreak) {
            currentStreak++;
          }
          if (i == currentStreak + 1 && i == 1) {
            // Practiced yesterday, but not today. Streak continues.
            currentStreak++;
          } else if (i == currentStreak + 1 && i > 1) {
            // Gap
          }
        }
      }
    }

    // More accurate streak calculation
    int tempStreak = 0;
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final heatmapDay = data[dateStr];

      if (i == 0) {
        if (heatmapDay != null && heatmapDay.sessionCount > 0) {
          tempStreak++;
        }
        continue;
      }

      if (heatmapDay != null && heatmapDay.sessionCount > 0) {
        tempStreak++;
      } else {
        break;
      }
    }
    currentStreak = tempStreak;

    final avgScore = activeDays > 0
        ? (totalScore / activeDays).toStringAsFixed(0)
        : '0';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('🔥', '$currentStreak', 'Streak', isDark),
        _buildStatItem('📅', '$activeDays', 'Active', isDark),
        _buildStatItem('🎯', '$avgScore%', 'Avg', isDark),
      ],
    );
  }

  Widget _buildStatItem(String emoji, String value, String label, bool isDark) {
    return Column(
      children: [
        Text(
          '$emoji $value',
          style: GoogleFonts.outfit(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

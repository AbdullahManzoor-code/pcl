import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class LearningHeatmap extends StatelessWidget {
  final Map<String, int> data;
  final int days;

  const LearningHeatmap({super.key, required this.data, this.days = 90});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Safety check for empty data or context
    if (days <= 0) return const SizedBox.shrink();

    final now = DateTime.now();
    final List<DateTime> dates = List.generate(
      days,
      (i) => now.subtract(Duration(days: days - 1 - i)),
    );

    // Group dates into weeks
    final List<List<DateTime>> weeks = [];
    List<DateTime> currentWeek = [];

    for (var date in dates) {
      currentWeek.add(date);
      if (date.weekday == DateTime.sunday || date == dates.last) {
        weeks.add(currentWeek);
        currentWeek = [];
      }
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
              Text(
                'Activity Heatmap',
                style: GoogleFonts.outfit(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Last $days days',
                style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            physics: const BouncingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: weeks
                  .map((week) => _buildWeekColumn(week, isDark))
                  .toList(),
            ),
          ),
          SizedBox(height: 16.h),
          _buildLegend(isDark),
        ],
      ),
    );
  }

  Widget _buildWeekColumn(List<DateTime> week, bool isDark) {
    // Fill empty days if week is incomplete
    final List<Widget> dayWidgets = [];

    // Check first day of first week to add padding if needed
    if (week.length < 7 && week.first.weekday != DateTime.monday) {
      for (int i = 0; i < week.first.weekday - 1; i++) {
        dayWidgets.add(_buildDaySquare(null, isDark));
      }
    }

    for (var date in week) {
      dayWidgets.add(_buildDaySquare(date, isDark));
    }

    return Column(children: dayWidgets);
  }

  Widget _buildDaySquare(DateTime? date, bool isDark) {
    if (date == null) {
      return Container(
        width: 12.w,
        height: 12.w,
        margin: EdgeInsets.all(2.r),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(2.r),
        ),
      );
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final count = data[dateStr] ?? 0;

    Color color;
    if (count == 0) {
      color = isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100;
    } else if (count < 3) {
      color = AppColors.primary.withOpacity(0.2);
    } else if (count < 6) {
      color = AppColors.primary.withOpacity(0.5);
    } else if (count < 9) {
      color = AppColors.primary.withOpacity(0.8);
    } else {
      color = AppColors.primary;
    }

    return Tooltip(
      message: '${DateFormat('MMM d').format(date)}: $count lessons',
      child: Container(
        width: 12.w,
        height: 12.w,
        margin: EdgeInsets.all(2.r),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  Widget _buildLegend(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Less',
          style: TextStyle(fontSize: 10.sp, color: Colors.grey),
        ),
        SizedBox(width: 4.w),
        _buildLegendSquare(0, isDark),
        _buildLegendSquare(2, isDark),
        _buildLegendSquare(5, isDark),
        _buildLegendSquare(8, isDark),
        _buildLegendSquare(10, isDark),
        SizedBox(width: 4.w),
        Text(
          'More',
          style: TextStyle(fontSize: 10.sp, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildLegendSquare(int count, bool isDark) {
    Color color;
    if (count == 0) {
      color = isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100;
    } else if (count < 3) {
      color = AppColors.primary.withOpacity(0.2);
    } else if (count < 6) {
      color = AppColors.primary.withOpacity(0.5);
    } else if (count < 9) {
      color = AppColors.primary.withOpacity(0.8);
    } else {
      color = AppColors.primary;
    }

    return Container(
      width: 10.w,
      height: 10.w,
      margin: EdgeInsets.symmetric(horizontal: 1.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }
}

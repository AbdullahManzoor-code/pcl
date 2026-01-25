import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pcl/app/data/models/achievement_model.dart';

/// Achievement card widget
class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback? onTap;

  const AchievementCard({super.key, required this.achievement, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: achievement.isUnlocked
              ? achievement.color.withOpacity(0.1)
              : (isDark ? Colors.grey[850] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: achievement.isUnlocked
                ? achievement.color.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: achievement.isUnlocked ? achievement.color : Colors.grey,
                shape: BoxShape.circle,
              ),
              child: Icon(achievement.icon, size: 32.sp, color: Colors.white),
            ),
            SizedBox(height: 12.h),

            // Title
            Text(
              achievement.title,
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: achievement.isUnlocked ? achievement.color : Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),

            // Description
            Text(
              achievement.description,
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12.h),

            // Progress
            if (!achievement.isUnlocked) ...[
              LinearProgressIndicator(
                value: achievement.progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(achievement.color),
                minHeight: 4.h,
                borderRadius: BorderRadius.circular(2.r),
              ),
              SizedBox(height: 4.h),
              Text(
                '${achievement.currentProgress}/${achievement.requiredCount}',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  color: Colors.grey[600],
                ),
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: achievement.color,
                    size: 16.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Unlocked',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: achievement.color,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

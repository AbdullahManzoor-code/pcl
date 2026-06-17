import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pcl/app/core/theme/app_theme.dart';
import 'package:pcl/app/core/widgets/next_components.dart';
import 'package:pcl/app/data/models/dashboard_api_models.dart';

class DecayAlertsWidget extends StatelessWidget {
  final List<DecayAlert> alerts;
  const DecayAlertsWidget({Key? key, required this.alerts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'Decay Alerts',
              style: GoogleFonts.outfit(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        ...alerts.map((alert) => _buildAlertCard(alert)).toList(),
      ],
    );
  }

  Widget _buildAlertCard(DecayAlert alert) {
    String urgency;
    Color urgencyColor;
    if (alert.daysPassed >= 14) {
      urgency = 'Urgent';
      urgencyColor = AppColors.error;
    } else if (alert.daysPassed >= 7) {
      urgency = 'Review Recommended';
      urgencyColor = Colors.orange;
    } else {
      urgency = 'Review Soon';
      urgencyColor = Colors.amber;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: NextCard(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.conceptName,
                    style: GoogleFonts.outfit(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Mastery dropped from ${(alert.originalMastery * 100).toStringAsFixed(0)}% to ${(alert.currentMastery * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  urgency,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: urgencyColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${alert.daysPassed} days ago',
                  style: GoogleFonts.inter(fontSize: 11.sp, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pcl/app/core/theme/app_theme.dart';
import 'package:pcl/app/data/models/dashboard_api_models.dart';

class SynergyBonusCard extends StatelessWidget {
  final List<SynergyBonus> bonuses;

  const SynergyBonusCard({Key? key, required this.bonuses}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (bonuses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.accent, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Recent Synergy Bonuses',
                  style: Get.textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: 10.h),
            ...bonuses.map((bonus) => _buildBonusItem(bonus)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBonusItem(SynergyBonus bonus) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: RichText(
        text: TextSpan(
          style: Get.textTheme.bodyMedium?.copyWith(
            color: Get.theme.colorScheme.onSurfaceVariant,
          ),
          children: [
            const TextSpan(text: 'Mastering '),
            TextSpan(
              text: '"${bonus.fromConcept}"',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: ' gave a '),
            TextSpan(
              text: '+${bonus.bonusAmount.toStringAsFixed(0)}% boost ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
            const TextSpan(text: 'to '),
            TextSpan(
              text: '"${bonus.toConcept}".',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

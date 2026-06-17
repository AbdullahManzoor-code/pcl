// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:pcl/app/core/theme/app_theme.dart';
// import 'package:pcl/app/data/models/dashboard_api_models.dart';

// class TransferBoostAlert extends StatelessWidget {
//   final List<TransferBoost> boosts;

//   const TransferBoostAlert({Key? key, required this.boosts}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     if (boosts.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     // Show only the most significant boost
//     final boost = boosts.first;

//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//       padding: EdgeInsets.all(12.w),
//       decoration: BoxDecoration(
//         color: AppColors.primary.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: AppColors.primary.withOpacity(0.3)),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.trending_up, color: AppColors.primary, size: 24.sp),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: RichText(
//               text: TextSpan(
//                 style: Get.textTheme.bodyMedium?.copyWith(
//                   color: Get.theme.colorScheme.onSurface,
//                 ),
//                 children: [
//                   const TextSpan(text: 'Your mastery in '),
//                   TextSpan(
//                     text: '${boost.sourceLanguage} ',
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   const TextSpan(text: 'is boosting your progress in '),
//                   TextSpan(
//                     text: '${boost.targetLanguage} ',
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   TextSpan(
//                     text: 'by +${boost.boostAmount.toStringAsFixed(0)}%!',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.success,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

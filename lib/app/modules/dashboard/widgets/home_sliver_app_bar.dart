import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animated_widgets.dart';
import '../../../core/widgets/special_cards.dart';
import '../../../core/utils/haptic_utils.dart';
import '../controllers/dashboard_controller.dart';

class HomeSliverAppBar extends StatelessWidget {
  final DashboardController controller;

  const HomeSliverAppBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 280.h,
      floating: false,
      pinned: true,
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      surfaceTintColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 80.h, // Increased for the greeting
      title: _buildHeader(context),
      titleSpacing: 20.w,
      centerTitle: false,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: _buildStreakCard(context),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    if (hour >= 12 && hour < 17) greeting = 'Good Afternoon';
    if (hour >= 17) greeting = 'Good Evening';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                greeting,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              Obx(
                () => Text(
                  controller.user.value.name ?? 'User',
                  style: GoogleFonts.outfit(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            AnimatedTapScale(
              onTap: () {
                HapticUtils.lightImpact();
                controller.goToNotifications();
              },
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.primary.withOpacity(0.05),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: isDark ? Colors.white70 : AppColors.primary,
                  size: 28.sp,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            AnimatedTapScale(
              onTap: () => controller.goToProfile(),
              child: Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Obx(
                  () => CircleAvatar(
                    radius: 22.r,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      (controller.user.value.email!.isNotEmpty
                              ? controller.user.value.email![0]
                              : 'U')
                          .toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStreakCard(BuildContext context) {
    return const StreakCelebrationCard(
      streak: 12,
      message: 'You\'re on fire! Keep it up for 3 more days to reach 15!',
      showCelebration: true,
    );
  }
}

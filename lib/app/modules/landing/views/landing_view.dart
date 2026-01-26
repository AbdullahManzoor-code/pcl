import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/landing_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_utils.dart';

class LandingView extends GetView<LandingController> {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.surfaceGradientDark
              : AppColors.surfaceGradientLight,
        ),
        child: Column(
          children: [
            _buildNavbar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeroSection(context, isDark),
                    _buildFeaturesSection(context, isDark),
                    _buildFooter(context, isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavbar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkBg.withOpacity(0.8)
            : Colors.white.withOpacity(0.8),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          return Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.code_rounded,
                  color: AppColors.primary,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 12.w),
              if (!isMobile)
                Text(
                  'LearnRL',
                  style: GoogleFonts.outfit(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: isDark ? Colors.white : AppColors.darkBg,
                  ),
                ),
              const Spacer(),
              if (isMobile) ...[
                TextButton(
                  onPressed: () {
                    HapticUtils.lightImpact();
                    controller.navigateToLogin();
                  },
                  child: Text(
                    'Sign In',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : AppColors.darkBg,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
              ],
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  onPressed: () {
                    HapticUtils.mediumImpact();
                    controller.navigateToRegister();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16.w : 28.w,
                      vertical: 14.h,
                    ),
                  ),
                  child: Text(
                    'Get Started',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 100.h, horizontal: 24.w),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(color: AppColors.primary.withOpacity(0.15)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: AppColors.primary, size: 16.sp),
                SizedBox(width: 8.w),
                Text(
                  'AI-POWERED LEARNING',
                  style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 11.sp,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40.h),
          Text(
            'Master Programming\nwith Intelligence',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 42.sp,
              fontWeight: FontWeight.w800,
              height: 1.1,
              color: isDark ? Colors.white : AppColors.darkBg,
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Experience a personalized learning path that adapts\nto your unique speed, goals, and style.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              color: isDark ? Colors.white70 : Colors.black54,
              height: 1.6,
            ),
          ),
          SizedBox(height: 56.h),
          SizedBox(
            width: 260.w,
            height: 64.h,
            child: ElevatedButton(
              onPressed: () {
                HapticUtils.mediumImpact();
                controller.navigateToRegister();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: AppColors.primary.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Start Free Journey',
                    style: GoogleFonts.inter(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Icon(Icons.arrow_forward_rounded, size: 22.sp),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 24.w),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.02)
            : Colors.black.withOpacity(0.02),
      ),
      child: Column(
        children: [
          Text(
            'Future-Proof Learning',
            style: GoogleFonts.outfit(
              fontSize: 30.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.darkBg,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Everything you need to master modern technology.',
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          SizedBox(height: 64.h),
          Wrap(
            spacing: 24.w,
            runSpacing: 24.h,
            alignment: WrapAlignment.center,
            children: [
              _buildFeatureCard(
                context: context,
                isDark: isDark,
                icon: Icons.rocket_launch_rounded,
                title: 'AI Paths',
                description: 'Custom curriculum that evolves with your skills.',
                color: const Color(0xFF3B82F6),
              ),
              _buildFeatureCard(
                context: context,
                isDark: isDark,
                icon: Icons.auto_awesome_motion_rounded,
                title: 'Adaptive Practice',
                description: 'Smart challenges that target your learning gaps.',
                color: const Color(0xFF10B981),
              ),
              _buildFeatureCard(
                context: context,
                isDark: isDark,
                icon: Icons.analytics_rounded,
                title: 'Data Insights',
                description: 'Visual breakdowns of your mastery journey.',
                color: const Color(0xFF8B5CF6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      width: 320.w,
      padding: EdgeInsets.all(32.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(icon, color: color, size: 28.sp),
          ),
          SizedBox(height: 24.h),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.darkBg,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              color: isDark
                  ? Colors.white.withOpacity(0.7)
                  : Colors.black.withOpacity(0.5),
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(48.r),
      color: AppColors.darkBg,
      child: Column(
        children: [
          Icon(Icons.code, color: Colors.white.withOpacity(0.3), size: 48.sp),
          SizedBox(height: 24.h),
          Text(
            '© 2026 LearnRL. All rights reserved.',
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/landing_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/haptic_utils.dart';

class LandingView extends GetView<LandingController> {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [Colors.white, const Color(0xFFF0F9FF)],
          ),
        ),
        child: Column(
          children: [
            _buildNavbar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeroSection(context),
                    _buildFeaturesSection(context),
                    _buildFooter(context),
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          return Row(
            children: [
              Icon(Icons.code, color: const Color(0xFF2563EB), size: 32.sp),
              SizedBox(width: 8.w),
              if (!isMobile)
                Text(
                  'LearnRL',
                  style: GoogleFonts.inter(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const Spacer(),
              if (isMobile) ...[
                TextButton(
                  onPressed: () {
                    HapticUtils.lightImpact();
                    Get.toNamed('/auth');
                  },
                  child: Text(
                    'Sign In',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
              ],
              ElevatedButton(
                onPressed: () {
                  HapticUtils.mediumImpact();
                  Get.toNamed('/register');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16.w : 24.w,
                    vertical: 12.h,
                  ),
                ),
                child: Text(
                  isMobile ? 'Get Started' : 'Get Started',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 80.h, horizontal: 24.w),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: const Color(0xFF2563EB).withOpacity(0.2),
              ),
            ),
            child: Text(
              '✨ AI-Powered Learning Platform',
              style: GoogleFonts.inter(
                color: const Color(0xFF2563EB),
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF3B82F6)],
            ).createShader(bounds),
            child: Text(
              'Master Programming\nwith AI Guidance',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 48.sp,
                fontWeight: FontWeight.w900,
                height: 1.1,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Personalized learning paths, interactive quizzes, and intelligent feedback\nto help you learn faster and more effectively.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  HapticUtils.mediumImpact();
                  Get.toNamed('/register');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 20.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Start Learning Now',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20.sp),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80.h, horizontal: 24.w),
      child: Column(
        children: [
          Text(
            'Why Choose LearnRL?',
            style: GoogleFonts.inter(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 64),
          Wrap(
            spacing: 32.w,
            runSpacing: 32.h,
            alignment: WrapAlignment.center,
            children: [
              _buildFeatureCard(
                icon: Icons.auto_awesome,
                title: 'AI-Driven Paths',
                description:
                    'Customized curriculum based on your goals and pace.',
                color: const Color(0xFF3B82F6),
              ),
              _buildFeatureCard(
                icon: Icons.psychology,
                title: 'Smart Assessment',
                description:
                    'Adaptive quizzes that evolve with your knowledge.',
                color: const Color(0xFF10B981),
              ),
              _buildFeatureCard(
                icon: Icons.timeline,
                title: 'Progress Tracking',
                description: 'Visual analytics to monitor your growth journey.',
                color: const Color(0xFF8B5CF6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20.r,
            offset: Offset(0, 10.h),
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
            child: Icon(icon, color: color, size: 32.sp),
          ),
          SizedBox(height: 24.h),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(48.r),
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          Icon(Icons.code, color: Colors.white.withOpacity(0.5), size: 48.sp),
          SizedBox(height: 24.h),
          Text(
            '© 2024 LearnRL. All rights reserved.',
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}

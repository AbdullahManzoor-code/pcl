import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.violet600],
          ),
        ),
        child: Stack(
          children: [
            // Background patterns
            Positioned(
              top: -100.h,
              right: -100.w,
              child: Opacity(
                opacity: 0.1,
                child: Image.network(
                  'https://ouch-cdn2.icons8.com/P_V_C-8S_v_r_W_l_j_X_o_M_z_S_m_X_v_o_S_M_z_X.png',
                  width: 400.w,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.auto_awesome_rounded,
                    size: 320.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(seconds: 1),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: 0.8 + (0.2 * value),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.code_rounded,
                          size: 60.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Padding(
                          padding: EdgeInsets.only(top: 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Text(
                          'PCL LEARNING',
                          style: GoogleFonts.outfit(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Master Programming with AI',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 50.h,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 30.w,
                  height: 30.w,
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white70),
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pcl/app/core/widgets/advanced_ui.dart';
import '../controllers/auth_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/auth_components.dart';
import '../../../core/widgets/enhanced_navigation.dart';
import '../../../core/widgets/animated_widgets.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../services/validation_service.dart';

/// Mobile-native login screen
class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final validationService = Get.find<ValidationService>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40.h),

              // Logo/Header with fade-in animation
              FadeInAnimation(
                delay: const Duration(milliseconds: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 32.sp,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Welcome text
                    Text(
                      'Welcome Back!',
                      style: GoogleFonts.outfit(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Sign in to continue your learning journey',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40.h),

              // Email field
              SlideInAnimation(
                index: 0,
                child: AuthTextField(
                  label: 'Email',
                  hintText: 'Enter your email',
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_rounded,
                  validator: validationService.validateEmail,
                ),
              ),

              SizedBox(height: 20.h),

              // Password field
              SlideInAnimation(
                index: 1,
                child: AuthTextField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  controller: controller.passwordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                ),
              ),

              SizedBox(height: 16.h),

              // Remember me & Forgot password
              SlideInAnimation(
                index: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              HapticUtils.selectionClick();
                              controller.rememberMe.value =
                                  !controller.rememberMe.value;
                            },
                            child: Container(
                              width: 20.w,
                              height: 20.w,
                              decoration: BoxDecoration(
                                color: controller.rememberMe.value
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                  color: controller.rememberMe.value
                                      ? AppColors.primary
                                      : (isDark
                                            ? AppColors.darkBorder
                                            : AppColors.lightBorder),
                                  width: 2,
                                ),
                              ),
                              child: controller.rememberMe.value
                                  ? Icon(
                                      Icons.check_rounded,
                                      size: 14.sp,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Remember me',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        HapticUtils.lightImpact();
                        // Navigate to forgot password
                        // Get.toNamed('/forgot-password');
                      },
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              // Login button
              SlideInAnimation(
                index: 3,
                child: Obx(
                  () => LoadingButton(
                    text: 'Sign In',
                    icon: Icons.login_rounded,
                    isLoading: controller.isLoading.value,
                    onPressed: () {
                      HapticUtils.mediumImpact();
                      controller.login();
                    },
                    isFullWidth: true,
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Divider
              SlideInAnimation(
                index: 4,
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'OR',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Google Sign-In button
              SlideInAnimation(
                index: 5,
                child: Obx(
                  () => AnimatedTapScale(
                    onTap: () {
                      HapticUtils.mediumImpact();
                      controller.signInWithGoogle();
                    },
                    child: SocialLoginButton(
                      text: 'Continue with Google',
                      iconPath: 'assets/icons/google.png', // Add Google icon
                      onPressed: () => controller.signInWithGoogle(),
                      isLoading: controller.isGoogleLoading.value,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // Sign up link
              SlideInAnimation(
                index: 6,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          HapticUtils.lightImpact();
                          Get.toNamed('/register');
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}

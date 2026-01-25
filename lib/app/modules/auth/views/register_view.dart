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

/// Mobile-native signup screen
class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

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

              // Header
              FadeInAnimation(
                delay: const Duration(milliseconds: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    IconButton(
                      onPressed: () {
                        HapticUtils.lightImpact();
                        Get.back();
                      },
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    SizedBox(height: 24.h),

                    // Title
                    Text(
                      'Create Account',
                      style: GoogleFonts.outfit(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Start your learning journey today',
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

              // Full Name field
              SlideInAnimation(
                index: 0,
                child: AuthTextField(
                  label: 'Full Name',
                  hintText: 'Enter your full name',
                  controller: controller.nameController,
                  prefixIcon: Icons.person_rounded,
                  validator: validationService.validateName,
                ),
              ),

              SizedBox(height: 20.h),

              // Email field
              SlideInAnimation(
                index: 1,
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
                index: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AuthTextField(
                      label: 'Password',
                      hintText: 'Create a password',
                      controller: controller.passwordController,
                      isPassword: true,
                      prefixIcon: Icons.lock_rounded,
                      validator: validationService.validatePassword,
                      onChanged: (value) {
                        // Trigger password strength update
                        controller.password.value = value;
                      },
                    ),
                    // Password strength indicator
                    Obx(
                      () => PasswordStrengthIndicator(
                        password: controller.password.value,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Confirm Password field
              SlideInAnimation(
                index: 3,
                child: AuthTextField(
                  label: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  controller: controller.confirmPasswordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_rounded,
                  validator: (value) =>
                      validationService.validateConfirmPassword(
                        controller.passwordController.text,
                        value,
                      ),
                ),
              ),

              SizedBox(height: 20.h),

              // Terms & Conditions checkbox
              SlideInAnimation(
                index: 4,
                child: Obx(
                  () => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticUtils.selectionClick();
                          controller.acceptTerms.value =
                              !controller.acceptTerms.value;
                        },
                        child: Container(
                          width: 20.w,
                          height: 20.w,
                          decoration: BoxDecoration(
                            color: controller.acceptTerms.value
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: controller.acceptTerms.value
                                  ? AppColors.primary
                                  : (isDark
                                        ? AppColors.darkBorder
                                        : AppColors.lightBorder),
                              width: 2,
                            ),
                          ),
                          child: controller.acceptTerms.value
                              ? Icon(
                                  Icons.check_rounded,
                                  size: 14.sp,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'Terms & Conditions',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // Sign Up button
              SlideInAnimation(
                index: 5,
                child: Obx(
                  () => LoadingButton(
                    text: 'Create Account',
                    icon: Icons.person_add_rounded,
                    isLoading: controller.isLoading.value,
                    onPressed: () {
                      if (!controller.acceptTerms.value) {
                        ToastNotification.show(
                          context,
                          message: 'Please accept Terms & Conditions',
                          type: ToastType.warning,
                        );
                        return;
                      }
                      HapticUtils.mediumImpact();
                      controller.register();
                    },
                    isFullWidth: true,
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Divider
              SlideInAnimation(
                index: 6,
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

              // Google Sign-Up button
              SlideInAnimation(
                index: 7,
                child: Obx(
                  () => AnimatedTapScale(
                    onTap: () {
                      HapticUtils.mediumImpact();
                      controller.signInWithGoogle();
                    },
                    child: SocialLoginButton(
                      text: 'Sign up with Google',
                      iconPath: 'assets/icons/google.png',
                      onPressed: () => controller.signInWithGoogle(),
                      isLoading: controller.isGoogleLoading.value,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // Sign in link
              SlideInAnimation(
                index: 8,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
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
                          Get.back();
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Sign In',
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

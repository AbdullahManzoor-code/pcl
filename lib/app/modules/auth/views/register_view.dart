import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/next_components.dart';
import '../controllers/auth_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 768) {
            return _buildDesktopLayout(context);
          }
          return _buildMobileLayout(context);
        },
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Left Side - Hero/Illustration
        Expanded(
          flex: 1,
          child: Container(
            color: AppColors.darkBg, // Using dark background
            padding: EdgeInsets.all(48.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.school,
                    color: AppColors.secondary,
                    size: 48.sp,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Start Your Journey',
                  style: GoogleFonts.inter(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Create an account to track your progress, practice with AI, and master new programming skills.',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                // Checklist
                _buildChecklistItem('Personalized Learning Paths'),
                const SizedBox(height: 16),
                _buildChecklistItem('Interactive AI Practice'),
                const SizedBox(height: 16),
                _buildChecklistItem('Real-time Progress Tracking'),
              ],
            ),
          ),
        ),
        // Right Side - Register Form
        Expanded(
          flex: 1,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 480.w),
                child: Padding(
                  padding: EdgeInsets.all(48.r),
                  child: SingleChildScrollView(
                    child: _buildRegisterForm(context),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistItem(String text) {
    return Row(
      children: [
        Icon(Icons.check_circle, color: AppColors.success, size: 24.sp),
        SizedBox(width: 12.w),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'LearnRL',
                style: GoogleFonts.outfit(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 32.h),
              NextCard(
                showShadow: true,
                padding: EdgeInsets.all(32.r),
                child: _buildRegisterForm(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Create Account',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Sign up to start learning with LearnRL',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        SizedBox(height: 32.h),
        NextInput(
          label: 'Full Name',
          controller: controller.nameController,
          placeholder: 'John Doe',
          prefixIcon: Icons.person_outline_rounded,
        ),
        SizedBox(height: 16.h),
        NextInput(
          label: 'Email',
          controller: controller.emailController,
          placeholder: 'john@example.com',
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16.h),
        NextInput(
          label: 'Password',
          controller: controller.passwordController,
          placeholder: '••••••••',
          obscureText: true,
          prefixIcon: Icons.lock_outline_rounded,
        ),
        SizedBox(height: 16.h),
        NextInput(
          label: 'Confirm Password',
          controller: controller.confirmPasswordController,
          placeholder: '••••••••',
          obscureText: true,
          prefixIcon: Icons.lock_outline_rounded,
        ),
        SizedBox(height: 32.h),
        Obx(
          () => NextButton(
            text: 'Create Account',
            onPressed: controller
                .login, // Note: using login logic as placeholder for signup
            isLoading: controller.isLoading.value,
            icon: Icons.arrow_forward_rounded,
            isFullWidth: true,
          ),
        ),
        SizedBox(height: 32.h),
        Row(
          children: [
            Expanded(
              child: Divider(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'or',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        Row(
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
            GestureDetector(
              onTap: () => Get.back(),
              child: Text(
                'Sign in',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

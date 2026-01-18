import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/next_components.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

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
            color: AppColors.darkSurface, // Centralized slate background
            padding: EdgeInsets.all(48.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'LearnRL',
                  style: GoogleFonts.outfit(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Master Programming with AI',
                  style: GoogleFonts.outfit(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Join thousands of developers mastering Python, JavaScript, and more with our AI-powered learning platform.',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 48.h),
                Container(
                  padding: EdgeInsets.all(24.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.primary,
                        size: 32.sp,
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Text(
                          '"The best way to learn to code. The AI feedback is game-changing."',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right Side - Login Form
        Expanded(
          flex: 1,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 480.w),
                  child: Padding(
                    padding: EdgeInsets.all(48.r),
                    child: _buildLoginForm(context),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                child: _buildLoginForm(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Welcome Back',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Login to your LearnRL account',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        SizedBox(height: 32.h),

        // Form Fields
        NextInput(
          label: 'Email',
          controller: controller.emailController,
          placeholder: 'john@example.com',
          prefixIcon: Icons.mail_outline_rounded,
        ),
        SizedBox(height: 16.h),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Forgot password?',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        NextInput(
          label: 'Password',
          controller: controller.passwordController,
          placeholder: '••••••••',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: true,
        ),
        SizedBox(height: 24.h),

        Obx(
          () => NextButton(
            text: 'Sign In',
            onPressed: controller.login,
            isLoading: controller.isLoading.value,
            icon: Icons.arrow_forward_rounded,
            isFullWidth: true,
          ),
        ),

        SizedBox(height: 32.h),

        // Divider
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
                'or continue with',
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

        // Social Login Placeholder
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(Icons.g_mobiledata_rounded, () {}),
            SizedBox(width: 16.w),
            _buildSocialButton(Icons.apple_rounded, () {}),
          ],
        ),

        SizedBox(height: 32.h),

        // Footer
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            GestureDetector(
              onTap: () => Get.toNamed('/register'),
              child: Text(
                'Sign up',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, size: 24.sp),
      ),
    );
  }
}

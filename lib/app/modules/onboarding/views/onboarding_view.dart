import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/onboarding_controller.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../core/widgets/next_components.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? AppColors.surfaceGradientDark
                  : AppColors.surfaceGradientLight,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, isDark),
                Expanded(
                  child: PageView(
                    controller: controller.pageController,
                    onPageChanged: controller.onPageChanged,
                    children: [
                      ...controller.tutorialSlides.map(
                        (slide) => _buildTutorialSlide(context, slide, isDark),
                      ),
                      _buildLanguageSelection(context, isDark),
                      _buildDifficultySelection(context, isDark),
                      _buildAssessmentIntro(context, isDark),
                      _buildFinalStep(context, isDark),
                    ],
                  ),
                ),
                _buildFooter(context, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        children: [
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStepIndicator(
                  0,
                  controller.currentPage.value >= 0,
                  isDark,
                ),
                _buildStepDot(controller.currentPage.value == 1, isDark),
                _buildStepDot(controller.currentPage.value == 2, isDark),
                _buildStepIndicator(
                  1,
                  controller.currentPage.value >= 3,
                  isDark,
                ),
                _buildStepIndicator(
                  2,
                  controller.currentPage.value >= 4,
                  isDark,
                ),
                _buildStepIndicator(
                  3,
                  controller.currentPage.value >= 5,
                  isDark,
                ),
                _buildStepIndicator(
                  4,
                  controller.currentPage.value >= 6,
                  isDark,
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Obx(() {
            String title = "";
            String subtitle = "";
            final page = controller.currentPage.value;
            if (page < 3) {
              title = controller.tutorialSlides[page]['title'] as String;
              subtitle = controller.tutorialSlides[page]['subtitle'] as String;
            } else if (page == 3) {
              title = "Choose Your Language";
              subtitle = "Select a programming language to start your journey";
            } else if (page == 4) {
              title = "Select Difficulty";
              subtitle = "Choose a level that matches your experience";
            } else if (page == 5) {
              title = "Skill Assessment";
              subtitle = "Let's see your current proficiency level";
            } else {
              title = "You're All Set!";
              subtitle = "Your personalized learning path is ready";
            }
            return Column(
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.darkBg,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(fontSize: 16.sp, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, bool isActive, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary
            : (isDark ? AppColors.darkSurface : Colors.white),
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive
              ? AppColors.primary
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: 2.w,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8.r,
                  offset: Offset(0, 4.h),
                ),
              ]
            : [],
      ),
      child: Center(
        child: isActive && step < controller.currentPage.value
            ? Icon(Icons.check, size: 16.sp, color: Colors.white)
            : Text(
                "${step + 1}",
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isActive
                      ? Colors.white
                      : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
                ),
              ),
      ),
    );
  }

  Widget _buildStepDot(bool isActive, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      width: isActive ? 12.w : 6.w,
      height: 6.w,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildTutorialSlide(
    BuildContext context,
    Map<String, dynamic> slide,
    bool isDark,
  ) {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(40.r),
            decoration: BoxDecoration(
              color: (slide['color'] as Color).withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Image.network(
              slide['image'] as String,
              width: 200.w,
              height: 200.w,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.image_outlined,
                size: 100.sp,
                color: slide['color'] as Color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentIntro(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.all(40.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.assignment_turned_in_rounded,
              size: 80.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 32.h),
          Text(
            "Quick Evaluation",
            style: GoogleFonts.outfit(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.darkBg,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            "Complete a 5-minute initial assessment to help our AI customize your starting point.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelection(BuildContext context, bool isDark) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(24.r),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.85,
      ),
      itemCount: controller.languages.length,
      itemBuilder: (context, index) {
        final lang = controller.languages[index];
        return Obx(() {
          final isSelected = controller.selectedLanguage.value == lang['id'];
          return InkWell(
            onTap: () {
              HapticUtils.selectionClick();
              controller.selectLanguage(lang['id'] as String);
            },
            borderRadius: BorderRadius.circular(24.r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: 2.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : (isDark
                              ? Colors.black.withOpacity(0.2)
                              : Colors.black.withOpacity(0.03)),
                    blurRadius: 20.r,
                    offset: Offset(0, 8.h),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  if (isSelected)
                    Positioned(
                      top: 12.h,
                      right: 12.w,
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 14.sp,
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: (lang['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Icon(
                            _getLanguageIcon(lang['logo'] as String),
                            size: 32.sp,
                            color: lang['color'] as Color,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          lang['name'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          lang['version'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  IconData _getLanguageIcon(String logo) {
    switch (logo) {
      case 'python':
        return Icons.terminal;
      case 'javascript':
        return Icons.code;
      case 'java':
        return Icons.coffee;
      case 'cpp':
        return Icons.developer_board;
      case 'go':
        return Icons.layers;
      default:
        return Icons.code;
    }
  }

  Widget _buildDifficultySelection(BuildContext context, bool isDark) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(24.r),
      itemCount: controller.difficultyLevels.length,
      separatorBuilder: (context, index) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final level = controller.difficultyLevels[index];
        return Obx(() {
          final isSelected = controller.selectedDifficulty.value == level['id'];
          return InkWell(
            onTap: () {
              HapticUtils.selectionClick();
              controller.selectDifficulty(level['id'] as String);
            },
            borderRadius: BorderRadius.circular(20.r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: 2.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : (isDark
                              ? Colors.black.withOpacity(0.2)
                              : Colors.black.withOpacity(0.04)),
                    blurRadius: 15.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: (level['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Text(
                        level['icon'] as String,
                        style: TextStyle(fontSize: 24.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          level['name'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          level['description'] as String,
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
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 24.sp,
                    ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildFinalStep(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(32.r),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.rocket_launch,
                size: 80.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              "Start Learning Now!",
              style: GoogleFonts.inter(
                fontSize: 20.sp, // Reduced from 24
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12.h),
            Obx(
              () => Text(
                "Your personalized roadmap for ${controller.selectedLanguage.value} is ready.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 32.h),
      child: Obx(
        () => Column(
          children: [
            if (controller.currentPage.value == 6)
              SizedBox(
                width: double.infinity,
                height: 60.h,
                child: NextButton(
                  text: "Start My Journey",
                  onPressed: () {
                    HapticUtils.mediumImpact();
                    controller.handleContinue();
                  },
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  controller.currentPage.value > 0
                      ? TextButton(
                          onPressed: () {
                            HapticUtils.lightImpact();
                            controller.pageController.previousPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Text(
                            "Back",
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  Row(
                    children: [
                      if (controller.currentPage.value >= 3)
                        TextButton(
                          onPressed: () {
                            HapticUtils.lightImpact();
                            controller.skip();
                          },
                          child: Text(
                            "Skip",
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      SizedBox(width: 12.w),
                      SizedBox(
                        width: 140.w,
                        child: NextButton(
                          text: controller.currentPage.value < 3
                              ? "Next"
                              : "Continue",
                          onPressed: () {
                            HapticUtils.mediumImpact();
                            controller.next();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

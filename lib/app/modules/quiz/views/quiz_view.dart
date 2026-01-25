import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/quiz_controller.dart';
import '../../../data/models/quiz_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/next_components.dart';
import '../../../core/utils/responsive_view.dart';
import '../../../core/utils/haptic_utils.dart';

class QuizView extends GetView<QuizController> {
  const QuizView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.surfaceGradientDark
              : AppColors.surfaceGradientLight,
        ),
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.quiz.value == null) {
              return const Center(child: Text('No quiz available'));
            }

            return ResponsiveView(
              mobile: _buildMobileLayout(context, isDark),
              desktop: _buildDesktopLayout(context, isDark),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isDark) {
    return Column(
      children: [
        _buildHeader(context, isDark),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: _buildQuizContent(context, isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, bool isDark) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 800.w),
        child: Column(
          children: [
            _buildHeader(context, isDark),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _buildQuizContent(context, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizContent(BuildContext context, bool isDark) {
    return Column(
      children: [
        _buildProgress(context, isDark),
        SizedBox(height: 24.h),
        _buildQuestionCard(context, isDark),
        SizedBox(height: 24.h),
        TextButton.icon(
          onPressed: () => _showQuestionsMap(
            context,
            controller.quiz.value!.questions.length,
          ),
          icon: Icon(Icons.grid_view_rounded, size: 20.sp),
          label: Text(
            'View All Questions',
            style: GoogleFonts.inter(fontSize: 14.sp),
          ),
        ),
        SizedBox(height: 32.h),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
                size: 24.sp,
              ),
              onPressed: () {
                HapticUtils.lightImpact();
                Get.back();
              },
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.primary, AppColors.info],
              ).createShader(bounds),
              child: Text(
                controller.isDiagnostic.value
                    ? 'Initial Assessment'
                    : 'Course Test',
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          // Timer Card
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: controller.timeLeft.value < 300
                    ? [AppColors.error, AppColors.rose600]
                    : [AppColors.primary, AppColors.info],
              ),
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: [
                BoxShadow(
                  color:
                      (controller.timeLeft.value < 300
                              ? AppColors.error
                              : AppColors.primary)
                          .withOpacity(0.3),
                  blurRadius: 8.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: Colors.white,
                  size: 18.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  controller.formattedTime,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(BuildContext context, bool isDark) {
    final currentQ = controller.currentIndex.value;
    final totalQ = controller.quiz.value!.questions.length;
    final progress = (currentQ + 1) / totalQ;

    return Column(
      children: [
        // Progress
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: progress),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 6.h,
                backgroundColor: isDark
                    ? AppColors.darkBorder
                    : AppColors.lightDivider,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              );
            },
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question ${currentQ + 1} of $totalQ',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
            Text(
              '${controller.answers.length} answered',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestionCard(BuildContext context, bool isDark) {
    final currentQ = controller.currentIndex.value;
    final totalQ = controller.quiz.value!.questions.length;
    final question = controller.quiz.value!.questions[currentQ];

    return NextCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.indigo600, AppColors.info],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Text(
              'Question ${currentQ + 1}',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.question,
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                SizedBox(height: 32.h),

                // Dynamic Question Content
                if (question.type == QuestionType.text)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: NextInput(
                      label: 'Your Answer',
                      placeholder: 'Type your answer here...',
                      controller: TextEditingController(
                        text: controller.answers[currentQ]?.toString() ?? '',
                      ),
                      validator: (val) => null,
                      prefixIcon: Icons.edit_note_rounded,
                      onChanged: (val) => controller.answers[currentQ] = val,
                    ),
                  )
                else
                  ...List.generate(question.options.length, (index) {
                    final isSelected = controller.answers[currentQ] == index;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: InkWell(
                        onTap: () {
                          HapticUtils.selectionClick();
                          controller.selectOption(index);
                        },
                        borderRadius: BorderRadius.circular(8.r),
                        child: Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                      ? AppColors.indigo600.withOpacity(0.3)
                                      : AppColors.lightDivider)
                                : (isDark
                                      ? AppColors.darkSurface
                                      : Colors.white),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark
                                        ? AppColors.darkBorder
                                        : AppColors.lightBorder),
                              width: 2.w,
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24.w,
                                height: 24.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : (isDark
                                              ? AppColors.darkTextTertiary
                                              : AppColors.lightTextTertiary),
                                    width: 2.w,
                                  ),
                                  color: isSelected ? AppColors.primary : null,
                                ),
                                child: isSelected
                                    ? Icon(
                                        Icons.check,
                                        size: 16.sp,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  question.options[index],
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.darkSurface,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                SizedBox(height: 24.h),

                // Navigation Buttons
                Row(
                  children: [
                    if (currentQ > 0)
                      Expanded(
                        child: NextButton(
                          text: 'Previous',
                          onPressed: () {
                            HapticUtils.lightImpact();
                            controller.prevQuestion();
                          },
                          outline: true,
                        ),
                      ),
                    if (currentQ > 0) SizedBox(width: 16.w),
                    Expanded(
                      child: NextButton(
                        text: currentQ == totalQ - 1 ? 'Submit Test' : 'Next',
                        onPressed: () {
                          HapticUtils.mediumImpact();
                          if (currentQ == totalQ - 1) {
                            _showSubmitConfirmation(context);
                          } else {
                            controller.nextQuestion();
                          }
                        },
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSubmitConfirmation(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.flag_rounded, size: 48.sp, color: AppColors.primary),
              SizedBox(height: 16.h),
              Text(
                'Submit Test?',
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'You have answered ${controller.answers.length} out of ${controller.quiz.value!.questions.length} questions.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.grey, fontSize: 14.sp),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: NextButton(
                      text: 'Cancel',
                      onPressed: () => Get.back(),
                      outline: true,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: NextButton(
                      text: 'Submit',
                      onPressed: () {
                        Get.back();
                        controller.submitQuiz();
                      },
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuestionsMap(BuildContext context, int total) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Questions',
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 12.h,
                    crossAxisSpacing: 12.w,
                  ),
                  itemCount: total,
                  itemBuilder: (context, index) {
                    final isAnswered = controller.answers.containsKey(index);
                    final isCurrent = controller.currentIndex.value == index;

                    Color bgColor;
                    Color textColor;
                    Color borderColor;

                    if (isCurrent) {
                      borderColor = AppColors.primary;
                      bgColor = isDark
                          ? AppColors.indigo600.withOpacity(0.3)
                          : AppColors.lightDivider;
                      textColor = AppColors.primary;
                    } else if (isAnswered) {
                      borderColor = AppColors.secondary;
                      bgColor = isDark
                          ? AppColors.successBgDark
                          : AppColors.successBgLight;
                      textColor = isDark
                          ? AppColors.successTextDark
                          : AppColors.successTextLight;
                    } else {
                      borderColor = isDark
                          ? AppColors.darkBorder
                          : Colors.grey.shade300;
                      bgColor = isDark ? AppColors.darkSurface : Colors.white;
                      textColor = isDark
                          ? AppColors.darkTextSecondary
                          : Colors.grey.shade700;
                    }

                    return InkWell(
                      onTap: () {
                        controller.jumpToQuestion(index);
                        Get.back();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: bgColor,
                          border: Border.all(color: borderColor, width: 2.w),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

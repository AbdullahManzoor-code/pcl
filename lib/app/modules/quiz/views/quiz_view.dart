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
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../routes/app_pages.dart';

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
            final showSkeleton = controller.questions.isEmpty && 
                (controller.isSelectingQuestions.value || controller.isPollingQuestions.value || controller.isInitializingSession.value);

            Widget mainContent;
            
            if (controller.questions.isEmpty && !showSkeleton) {
              mainContent = Center(
                child: Text(
                  'Failed to load test questions.',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              );
            } else {
              mainContent = ResponsiveView(
                mobile: _buildMobileLayout(context, isDark, isSkeleton: showSkeleton),
                desktop: _buildDesktopLayout(context, isDark, isSkeleton: showSkeleton),
              );
            }

            return Stack(
              children: [
                mainContent,
                if (controller.isInitializingSession.value || (controller.questions.isEmpty && (controller.isSelectingQuestions.value || controller.isPollingQuestions.value)))
                  Positioned.fill(
                    child: Container(
                      color: isDark ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.4),
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 32.h),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface.withOpacity(0.95) : Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(24.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 32.r,
                                spreadRadius: 8.r,
                                offset: Offset(0, 8.h),
                              ),
                            ],
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.5),
                              width: 2.w,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 64.w,
                                    height: 64.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 4.w,
                                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                      backgroundColor: AppColors.primary.withOpacity(0.2),
                                    ),
                                  ),
                                  Icon(Icons.auto_awesome, color: AppColors.primary, size: 28.sp),
                                ],
                              ),
                              SizedBox(height: 24.h),
                              Text(
                                controller.isInitializingSession.value 
                                    ? 'Creating Test Session...' 
                                    : 'Generating AI Questions...',
                                style: GoogleFonts.inter(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Personalizing your curriculum',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isDark, {bool isSkeleton = false}) {
    return Column(
      children: [
        _buildHeader(context, isDark),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: isSkeleton ? _buildSkeletonContent(context, isDark) : _buildQuizContent(context, isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, bool isDark, {bool isSkeleton = false}) {
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
                child: isSkeleton ? _buildSkeletonContent(context, isDark) : _buildQuizContent(context, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLayout(BuildContext context, bool isDark) {
     return _buildMobileLayout(context, isDark, isSkeleton: true);
  }

  Widget _buildSkeletonContent(BuildContext context, bool isDark) {
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Progress Skeleton
        Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Column(
            children: [
              Container(
                height: 6.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 100.w, height: 14.h, color: Colors.white),
                  Container(width: 80.w, height: 14.h, color: Colors.white),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        
        // Question Card Skeleton
        NextCard(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 60.h,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightDivider,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                ),
                padding: EdgeInsets.all(20.r),
                child: Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(width: 120.w, height: 20.h, color: Colors.white),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(24.r),
                child: Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: double.infinity, height: 20.h, color: Colors.white),
                      SizedBox(height: 8.h),
                      Container(width: 200.w, height: 20.h, color: Colors.white),
                      SizedBox(height: 32.h),
                      ...List.generate(4, (index) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: Container(
                          height: 56.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      )),
                      SizedBox(height: 24.h),
                      Row(
                        children: [
                           Expanded(child: Container(height: 48.h, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.r)))),
                           SizedBox(width: 16.w),
                           Expanded(child: Container(height: 48.h, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.r)))),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 32.h),
      ],
    );
  }

  Widget _buildQuizContent(BuildContext context, bool isDark) {
    return Column(
      children: [
        if (controller.isPollingQuestions.value)
          Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isDark ? AppColors.indigo600.withOpacity(0.2) : AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.info.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                   SizedBox(
                     width: 16.w,
                     height: 16.w,
                     child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                   ),
                   SizedBox(width: 12.w),
                   Expanded(
                     child: Text(
                       'AI is preparing more questions...',
                       style: GoogleFonts.inter(
                         fontSize: 14.sp,
                         fontWeight: FontWeight.w500,
                         color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                       ),
                     ),
                   ),
                ],
              ),
            ),
          ),
        _buildProgress(context, isDark),
        SizedBox(height: 24.h),
        _buildQuestionCard(context, isDark),
        SizedBox(height: 24.h),
        TextButton.icon(
          onPressed: () =>
              _showQuestionsMap(context, controller.questions.length),
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
    final totalQ = controller.questions.length;
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
    final totalQ = controller.questions.length;
    final question = controller.questions[currentQ];

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
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Question ${currentQ + 1}',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Navigate to Reports view with current question id
                    Get.toNamed(
                      Routes.reports,
                      arguments: {'questionId': question.id},
                    );
                  },
                  icon: Icon(
                    Icons.report_problem,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                  tooltip: 'Report this question',
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (question.questionData.mediaUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: CachedNetworkImage(
                      imageUrl: question.questionData.mediaUrl!,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Container(
                        height: 200.h,
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.lightDivider,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
                Text(
                  question.questionData.questionText,
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                if (question.questionData.codeSnippet != null) ...[
                  SizedBox(height: 16.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: SelectableText(
                      question.questionData.codeSnippet!,
                      style: GoogleFonts.firaCode(
                        fontSize: 14.sp,
                        color: const Color(0xFFE2E8F0),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 32.h),

                // Dynamic Question Content
                if (question.questionData.questionType == 'text' ||
                    question.questionData.questionType == 'essay' ||
                    question.questionData.options.isEmpty)
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
                      maxLines: question.questionData.questionType == 'essay'
                          ? 5
                          : 1,
                      onChanged: (val) => controller.answers[currentQ] = val,
                    ),
                  )
                else
                  ...List.generate(question.questionData.options.length, (
                    index,
                  ) {
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
                                  question.questionData.options[index].text,
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
                'You have answered ${controller.answers.length} out of ${controller.questions.length} questions.',
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
                    child: Obx(
                      () => NextButton(
                        text: 'Submit',
                        onPressed:
                            controller.answers.length <
                                controller.minSubmitQuestions
                            ? null
                            : () {
                                Get.back();
                                controller.submitQuiz();
                              },
                        color: AppColors.primary,
                      ),
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

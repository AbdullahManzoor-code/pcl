import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/results_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/next_components.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../data/models/quiz_model.dart';

class ResultsView extends GetView<ResultsController> {
  const ResultsView({super.key});

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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Score Ring Header
                const SizedBox(height: 16),
                _buildScoreRing(context, controller.percentage.value / 100),
                SizedBox(height: 32.h),
                Text(
                  'Test Completed!',
                  style: GoogleFonts.outfit(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.darkBg,
                  ),
                ),
                SizedBox(height: 8.h),
                Obx(
                  () => Text(
                    controller.conceptName.value,
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Here's how you performed",
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                SizedBox(height: 32.h),

                // Stats Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16.h,
                  crossAxisSpacing: 16.w,
                  childAspectRatio: 1.5,
                  children: [
                    Obx(
                      () => _buildStatCard(
                        context,
                        value: controller.grade.value,
                        label: 'Grade',
                        colors: [AppColors.accent, AppColors.warning],
                      ),
                    ),
                    Obx(
                      () => _buildStatCard(
                        context,
                        value:
                            '${controller.score}/${controller.totalQuestions}',
                        label: 'Score',
                        colors: [AppColors.primary, AppColors.indigo600],
                      ),
                    ),
                    Obx(
                      () => _buildStatCard(
                        context,
                        value: '${controller.percentage.value.toInt()}%',
                        label: 'Accuracy',
                        colors: [AppColors.secondary, AppColors.teal600],
                      ),
                    ),
                    Obx(
                      () => _buildStatCard(
                        context,
                        value: controller.timeTaken.value,
                        label: 'Time Taken',
                        colors: [AppColors.violet600, AppColors.rose600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),

                // Overall Progress
                NextCard(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Overall Progress',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                            Obx(
                              () => Text(
                                '${controller.percentage.value.toInt()}%',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Obx(
                          () => ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(
                                begin: 0.0,
                                end: controller.percentage.value / 100,
                              ),
                              duration: const Duration(milliseconds: 1500),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return LinearProgressIndicator(
                                  value: value,
                                  minHeight: 8,
                                  backgroundColor: isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightDivider,
                                  valueColor: const AlwaysStoppedAnimation(
                                    AppColors.secondary,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Analysis Sections (Strong / Areas to Improve)
                _buildAnalysisSection(
                  context,
                  title: 'Strong Topics',
                  icon: Icons.trending_up,
                  iconColor: AppColors.secondary,
                  iconBg: AppColors.secondary.withOpacity(0.3),
                  items: controller.strongTopics,
                  progressColor: AppColors.secondary,
                ),
                const SizedBox(height: 16),
                _buildAnalysisSection(
                  context,
                  title: 'Areas to Improve',
                  icon: Icons.trending_down,
                  iconColor: AppColors.error,
                  iconBg: AppColors.error.withOpacity(0.3),
                  items: controller.weakTopics,
                  progressColor: AppColors.error,
                ),
                const SizedBox(height: 32),

                // Detailed Question Review
                Text(
                  'Detailed Question Review',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.questions.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final question = controller.questions[index];
                      final selectedAns = controller.answers[index];

                      bool isCorrect = false;
                      if (question.type == QuestionType.mcq) {
                        isCorrect = selectedAns == question.correctAnswer;
                      } else {
                        final userAnswer = selectedAns
                            .toString()
                            .trim()
                            .toLowerCase();
                        final correctAnswer = (question.correctAnswerText ?? '')
                            .trim()
                            .toLowerCase();
                        isCorrect = userAnswer == correctAnswer;
                      }

                      return NextCard(
                        padding: const EdgeInsets.all(0),
                        child: Theme(
                          data: Theme.of(
                            context,
                          ).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding: EdgeInsets.all(16.r),
                            childrenPadding: EdgeInsets.fromLTRB(
                              16.w,
                              0,
                              16.w,
                              16.h,
                            ),
                            leading: Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: isCorrect
                                    ? (isDark
                                          ? AppColors.successBgDark
                                          : AppColors.successBgLight)
                                    : (isDark
                                          ? AppColors.errorBgDark
                                          : AppColors.errorBgLight),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isCorrect ? Icons.check : Icons.close,
                                color: isCorrect
                                    ? (isDark
                                          ? AppColors.successTextDark
                                          : AppColors.successTextLight)
                                    : (isDark
                                          ? AppColors.errorTextDark
                                          : AppColors.errorTextLight),
                                size: 20.sp,
                              ),
                            ),
                            title: Text(
                              'Question ${index + 1}',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            subtitle: Text(
                              question.question,
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 8.h),
                                  Text(
                                    question.question,
                                    style: GoogleFonts.inter(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  if (question.type == QuestionType.text)
                                    _buildTextAnswerReview(
                                      context,
                                      question,
                                      selectedAns,
                                      isCorrect,
                                    )
                                  else
                                    ...List.generate(question.options.length, (
                                      optIndex,
                                    ) {
                                      final isSelected =
                                          selectedAns == optIndex;
                                      final isThisCorrect =
                                          question.correctAnswer == optIndex;

                                      Color? bgColor;
                                      Color borderColor = isDark
                                          ? AppColors.darkBorder
                                          : AppColors.lightBorder;
                                      Color textColor = isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary;

                                      if (isThisCorrect) {
                                        bgColor = isDark
                                            ? AppColors.successBgDark
                                                  .withOpacity(0.3)
                                            : AppColors.successBgLight
                                                  .withOpacity(0.3);
                                        borderColor = AppColors.secondary;
                                        textColor = isDark
                                            ? AppColors.successTextDark
                                            : AppColors.successTextLight;
                                      } else if (isSelected && !isThisCorrect) {
                                        bgColor = isDark
                                            ? AppColors.errorBgDark.withOpacity(
                                                0.5,
                                              )
                                            : AppColors.errorBgLight
                                                  .withOpacity(0.3);
                                        borderColor = AppColors.error;
                                        textColor = isDark
                                            ? AppColors.errorTextDark
                                            : AppColors.errorTextLight;
                                      }

                                      return Container(
                                        margin: EdgeInsets.only(bottom: 8.h),
                                        padding: EdgeInsets.all(12.r),
                                        decoration: BoxDecoration(
                                          color: bgColor,
                                          border: Border.all(
                                            color: borderColor,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            if (isThisCorrect)
                                              Icon(
                                                Icons.check_circle,
                                                size: 16.sp,
                                                color: AppColors.secondary,
                                              )
                                            else if (isSelected)
                                              Icon(
                                                Icons.cancel,
                                                size: 16.sp,
                                                color: AppColors.error,
                                              )
                                            else
                                              SizedBox(width: 16.w),
                                            SizedBox(width: 12.w),
                                            Expanded(
                                              child: Text(
                                                question.options[optIndex],
                                                style: GoogleFonts.inter(
                                                  fontSize: 14.sp,
                                                  color: textColor,
                                                  fontWeight:
                                                      (isSelected ||
                                                          isThisCorrect)
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),

                                  // Mock Explanation
                                  SizedBox(height: 16.h),
                                  Container(
                                    padding: EdgeInsets.all(16.r),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.darkSurface
                                          : AppColors.lightBg,
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(
                                        color: isDark
                                            ? AppColors.darkBorder
                                            : AppColors.lightBorder,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.lightbulb_outline_rounded,
                                              size: 16.sp,
                                              color: isDark
                                                  ? AppColors.darkTextSecondary
                                                  : AppColors
                                                        .lightTextSecondary,
                                            ),
                                            SizedBox(width: 8.w),
                                            Text(
                                              'Explanation',
                                              style: GoogleFonts.inter(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? AppColors
                                                          .darkTextSecondary
                                                    : AppColors
                                                          .lightTextSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          "Here is a detailed explanation of why the correct answer is correct. (Mock explanation)",
                                          style: GoogleFonts.inter(
                                            fontSize: 13.sp,
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
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 32.h),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: NextButton(
                        text: 'Back to Dashboard',
                        onPressed: () {
                          HapticUtils.lightImpact();
                          controller.goToDashboard();
                        },
                        outline: true,
                        icon: Icons.home_outlined,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: NextButton(
                        text: 'Practice Again',
                        onPressed: () {
                          HapticUtils.mediumImpact();
                          controller.handlePracticeAgain();
                        },
                        icon: Icons.refresh_rounded,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreRing(BuildContext context, double percentage) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 180.w,
          height: 180.w,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: percentage),
            duration: const Duration(seconds: 2),
            curve: Curves.easeOutCirc,
            builder: (context, value, child) {
              return CircularProgressIndicator(
                value: value,
                strokeWidth: 12.w,
                backgroundColor: isDark
                    ? AppColors.darkSurface
                    : AppColors.lightBorder,
                valueColor: AlwaysStoppedAnimation(
                  percentage > 0.7
                      ? AppColors.success
                      : (percentage > 0.4 ? AppColors.accent : AppColors.error),
                ),
              );
            },
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${(percentage * 100).toInt()}%',
              style: GoogleFonts.outfit(
                fontSize: 48.sp,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.darkBg,
              ),
            ),
            Text(
              'CORRECT',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String value,
    required String label,
    required List<Color> colors,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.darkBg,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required RxList<Map<String, dynamic>> items,
    required Color progressColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (items.isEmpty) return const SizedBox.shrink();

      return NextCard(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: isDark ? iconColor.withOpacity(0.3) : iconBg,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(icon, color: iconColor, size: 20.sp),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              ...items.map((item) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () =>
                                  controller.practiceTopic(item['name']),
                              borderRadius: BorderRadius.circular(4.r),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['name'],
                                      style: GoogleFonts.inter(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Retake',
                                    style: GoogleFonts.inter(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 14.sp,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            '${item['accuracy']}%',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: progressColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999.r),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(
                            begin: 0.0,
                            end: (item['accuracy'] as int) / 100,
                          ),
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return LinearProgressIndicator(
                              value: value,
                              minHeight: 6.h,
                              backgroundColor: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightDivider,
                              valueColor: AlwaysStoppedAnimation(progressColor),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTextAnswerReview(
    BuildContext context,
    Question question,
    dynamic selectedAns,
    bool isCorrect,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAnswerBox(
          context: context,
          label: 'Your Answer',
          text: selectedAns?.toString() ?? '(No answer)',
          isCorrect: isCorrect,
          isDark: isDark,
        ),
        SizedBox(height: 12.h),
        if (!isCorrect)
          _buildAnswerBox(
            context: context,
            label: 'Correct Answer',
            text: question.correctAnswerText ?? '',
            isCorrect: true,
            isDark: isDark,
          ),
      ],
    );
  }

  Widget _buildAnswerBox({
    required BuildContext context,
    required String label,
    required String text,
    required bool isCorrect,
    required bool isDark,
  }) {
    final color = isCorrect ? AppColors.secondary : AppColors.error;
    final bgColor = isCorrect
        ? (isDark ? AppColors.successBgDark : AppColors.successBgLight)
        : (isDark ? AppColors.errorBgDark : AppColors.errorBgLight);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.3),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

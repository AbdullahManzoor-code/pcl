import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pcl/app/modules/reports/controllers/reports_controller.dart';
import 'package:pcl/app/routes/app_pages.dart';
import '../controllers/results_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/next_components.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../data/models/quiz_model.dart';
import '../../../data/models/exam_api_models.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ResultsView extends GetView<ResultsController> {
  ResultsView({super.key});
  final Controller = Get.put<ReportsController>(ReportsController());
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
                Obx(
                  () => _buildScoreRing(
                    context,
                    (controller.percentage.value / 100).clamp(0.0, 1.0),
                  ),
                ),
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
                        value: controller.grade,
                        label: 'Grade',
                        colors: [AppColors.accent, AppColors.warning],
                      ),
                    ),
                    Obx(
                      () => _buildStatCard(
                        context,
                        value:
                            '${controller.score.value}/${controller.totalQuestions.value}',
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
                SizedBox(height: 24.h),

                // Download Certificate Button (Visible if passing)
                Obx(
                  () => controller.percentage.value >= 70
                      ? Padding(
                          padding: EdgeInsets.only(bottom: 24.h),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: controller.downloadCertificate,
                              icon: const Icon(Icons.workspace_premium),
                              label: const Text('Download Certificate'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                textStyle: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                SizedBox(height: 8.h),

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
                                end: (controller.percentage.value / 100).clamp(
                                  0.0,
                                  1.0,
                                ),
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
                        SizedBox(height: 12.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              // Open reports page prefilled with question id
                              Get.toNamed(
                                Routes.reports,
                                arguments: {
                                  'questionId': Controller.questionId,
                                },
                              );
                            },
                            icon: Icon(Icons.report, size: 16.sp),
                            label: Text('Report'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                Obx(() {
                  if (controller.analysisStatus.value == 'completed') {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: _buildStatusBanner(
                      context,
                      'Analysis ${controller.analysisStatus.value}',
                      'The backend is still generating detailed recommendations for this session.',
                    ),
                  );
                }),
                _buildStrongTopicsSection(context),
                const SizedBox(height: 16),
                _buildErrorPatternsSection(context),
                const SizedBox(height: 16),
                _buildRecommendationsSection(context),
                const SizedBox(height: 16),
                _buildPrerequisiteGapsSection(context),
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
                      final isCorrect = question.isCorrect;

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
                              question.questionText ?? '',
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
                                  if (question.mediaUrl != null) ...[
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.r),
                                      child: CachedNetworkImage(
                                        imageUrl: question.mediaUrl!,
                                        width: double.infinity,
                                        fit: BoxFit.contain,
                                        placeholder: (context, url) =>
                                            Container(
                                              height: 150.h,
                                              color: isDark
                                                  ? AppColors.darkSurface
                                                  : AppColors.lightDivider,
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            const SizedBox.shrink(),
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                  ],
                                  Text(
                                    question.questionText ?? '',
                                    style: GoogleFonts.inter(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  if (question.codeSnippet != null) ...[
                                    SizedBox(height: 12.h),
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(12.r),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF0F172A)
                                            : const Color(0xFF1E293B),
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: SelectableText(
                                        question.codeSnippet!,
                                        style: GoogleFonts.firaCode(
                                          fontSize: 12.sp,
                                          color: const Color(0xFFE2E8F0),
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                  SizedBox(height: 16.h),
                                  if (question.options == null)
                                    _buildTextAnswerReview(
                                      context,
                                      question,
                                      question.selectedChoice,
                                      isCorrect,
                                    )
                                  else
                                    ...List.generate(question.options!.length, (
                                      optIndex,
                                    ) {
                                      final choiceLabels = ['A', 'B', 'C', 'D'];
                                      final optionLabel =
                                          choiceLabels[optIndex];
                                      final isSelected =
                                          question.selectedChoice ==
                                          optionLabel;
                                      final isThisCorrect =
                                          question.correctChoice == optionLabel;

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
                                                '${choiceLabels[optIndex]}. ${question.options![optIndex].text}',
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
                                          question.explanation ??
                                              "Here is a detailed explanation of why the correct answer is correct.",
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

  Widget _buildStatusBanner(
    BuildContext context,
    String title,
    String message,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NextCard(
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.hourglass_top,
                color: AppColors.warning,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    message,
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
      ),
    );
  }

  Widget _buildSourceBadge(BuildContext context, String? source) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color color;
    String label;

    if (source == 'llm') {
      color = AppColors.secondary;
      label = 'LLM';
    } else if (source == 'fallback') {
      color = AppColors.warning;
      label = 'Fallback';
    } else if (source == 'failed') {
      color = AppColors.error;
      label = 'Failed';
    } else if (source == 'pending') {
      color = AppColors.primary;
      label = 'Pending';
    } else if (source == 'none') {
      color = isDark
          ? AppColors.darkTextSecondary
          : AppColors.lightTextSecondary;
      label = 'N/A';
    } else {
      color = isDark
          ? AppColors.darkTextSecondary
          : AppColors.lightTextSecondary;
      label = 'Unknown';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStrongTopicsSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (controller.strongTopics.isEmpty) return const SizedBox.shrink();

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
                      color: AppColors.secondary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.trending_up,
                      color: AppColors.secondary,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Strong Topics',
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
              ...controller.strongTopics.map((topic) {
                final accuracy = topic.accuracy.clamp(0.0, 100.0);

                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => controller.practiceTopic(topic.name),
                              borderRadius: BorderRadius.circular(4.r),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      topic.name,
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
                            '${accuracy.toInt()}%',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999.r),
                        child: LinearProgressIndicator(
                          value: (accuracy / 100).clamp(0.0, 1.0),
                          minHeight: 6.h,
                          backgroundColor: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightDivider,
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildErrorPatternsSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
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
                      color: AppColors.error.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.error,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Error Patterns',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: _buildSourceBadge(
                      context,
                      controller.errorPatternsSource.value,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              if (controller.errorPatterns.isEmpty)
                Text(
                  'No error patterns detected. Great job!',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                )
              else
                ...controller.errorPatterns.map((pattern) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.lightBg,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  pattern.errorType,
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                '${pattern.count}',
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                          if (pattern.whyWrong != null &&
                              pattern.whyWrong!.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            Text(
                              pattern.whyWrong!,
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildRecommendationsSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
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
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.tips_and_updates,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Recommendations',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: _buildSourceBadge(
                      context,
                      controller.recommendationsSource.value,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              if (controller.recommendations.isEmpty)
                Text(
                  controller.analysisStatus.value == 'failed'
                      ? 'Analysis failed for this session, so recommendations could not be generated. Please retake the test to regenerate analysis.'
                      : 'Recommendations are being generated. This section updates automatically when analysis completes.',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                )
              else
                ...controller.recommendations.map((recommendation) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.lightBg,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recommendation.title,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            recommendation.description,
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
                  );
                }),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPrerequisiteGapsSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (controller.prerequisiteGaps.isEmpty) return const SizedBox.shrink();

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
                      color: AppColors.warning.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.flag_outlined,
                      color: AppColors.warning,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Prerequisite Gaps',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                  if (controller.overallReadiness.value != null) ...[
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        'Readiness ${(controller.overallReadiness.value! * 100).round()}%',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 16.h),
              ...controller.prerequisiteGaps.map((gap) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightBg,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gap.name,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          gap.recommendation,
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
                );
              }),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAnalysisSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required RxList<StrongTopic> items,
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
                              onTap: () => controller.practiceTopic(item.name),
                              borderRadius: BorderRadius.circular(4.r),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.name,
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
                            '${item.accuracy.toInt()}%',
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
                            end: (item.accuracy / 100).clamp(0.0, 1.0),
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
    QuestionResultPayload question,
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
            text: question.correctChoice ?? '',
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

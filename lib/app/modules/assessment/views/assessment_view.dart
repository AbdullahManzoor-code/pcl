import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/next_components.dart';
import '../controllers/assessment_controller.dart';
import '../../../core/utils/haptic_utils.dart';

class AssessmentView extends GetView<AssessmentController> {
  const AssessmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Initial Assessment'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar
              Obx(
                () => ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0.0,
                      end:
                          (controller.currentQuestionIndex.value + 1) /
                          controller.questions.length,
                    ),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return LinearProgressIndicator(
                        value: value,
                        backgroundColor: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightDivider,
                        minHeight: 8.h,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Question Counter
              Obx(
                () => Text(
                  'Question ${controller.currentQuestionIndex.value + 1}/${controller.questions.length}',
                  style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Question Text
              Obx(
                () => Text(
                  controller.questions[controller
                          .currentQuestionIndex
                          .value]['question']
                      as String,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize:
                        20.sp, // Reduced from 22 to be consistent with average
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 32.h),

              // Options
              Expanded(
                child: Obx(() {
                  final currentQIndex = controller.currentQuestionIndex.value;
                  final options =
                      controller.questions[currentQIndex]['options']
                          as List<String>;
                  final selectedAnswer = controller.answers[currentQIndex];

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: options.length,
                    separatorBuilder: (ctx, i) => SizedBox(height: 16.h),
                    itemBuilder: (context, index) {
                      final isSelected = selectedAnswer == index;
                      return InkWell(
                        onTap: () {
                          HapticUtils.selectionClick();
                          controller.selectAnswer(currentQIndex, index);
                        },
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 16.h,
                            horizontal: 20.w,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.05)
                                : (isDark
                                      ? AppColors.darkSurface
                                      : Colors.white),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark
                                        ? AppColors.darkBorder
                                        : AppColors.lightBorder),
                              width: 2.w,
                            ),
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
                                              ? Colors.white24
                                              : Colors.black12),
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
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Text(
                                  options[index],
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),

              // Navigation Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => controller.currentQuestionIndex.value > 0
                        ? TextButton(
                            onPressed: () {
                              HapticUtils.lightImpact();
                              controller.previousQuestion();
                            },
                            child: Text(
                              'Previous',
                              style: GoogleFonts.inter(fontSize: 14.sp),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  Obx(
                    () => SizedBox(
                      width: 140.w,
                      child: NextButton(
                        text:
                            controller.currentQuestionIndex.value ==
                                controller.questions.length - 1
                            ? 'Finish'
                            : 'Next',
                        onPressed:
                            controller.answers.containsKey(
                              controller.currentQuestionIndex.value,
                            )
                            ? () {
                                HapticUtils.mediumImpact();
                                controller.nextQuestion();
                              }
                            : null,
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
}

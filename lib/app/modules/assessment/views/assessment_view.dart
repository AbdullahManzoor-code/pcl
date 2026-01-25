import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

import '../controllers/assessment_controller.dart';
import '../../../core/utils/haptic_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AssessmentView extends GetView<AssessmentController> {
  const AssessmentView({super.key});

  @override
  Widget build(BuildContext context) {
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
                        backgroundColor: Colors.grey[200],
                        minHeight: 8.h,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
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
                    color: Theme.of(context).primaryColor,
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
                    fontSize: 22.sp,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
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
                                ? Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.shade300,
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
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey.shade400,
                                    width: 2.w,
                                  ),
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : null,
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
                    () => ElevatedButton(
                      onPressed:
                          controller.answers.containsKey(
                            controller.currentQuestionIndex.value,
                          )
                          ? () {
                              HapticUtils.mediumImpact();
                              controller.nextQuestion();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 32.w,
                          vertical: 12.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        controller.currentQuestionIndex.value ==
                                controller.questions.length - 1
                            ? 'Submit'
                            : 'Next',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/learning_controller.dart';
import '../../../core/widgets/app_code_editor.dart';
import '../../../core/utils/haptic_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class LearningView extends GetView<LearningController> {
  const LearningView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.topic['title'] ?? 'Learning')),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isQuizMode.value) {
            return _buildQuizView(context);
          } else {
            return _buildContentView(context);
          }
        }),
      ),
    );
  }

  Widget _buildContentView(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Topic Banner (Mock Image)
                  Container(
                    height: 200.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.image,
                        size: 80.sp,
                        color: Colors.blue.shade300,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Content Text (Simplified rendering)
                  Text(
                    controller.content,
                    style: GoogleFonts.inter(fontSize: 16.sp, height: 1.6),
                  ),

                  if (controller.topic['code'] != null) ...[
                    SizedBox(height: 24.h),
                    AppCodeEditor(
                      code: controller.topic['code'],
                      language: controller.topic['language'] ?? 'dart',
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticUtils.mediumImpact();
                controller.startQuiz();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Differentiate typical action
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Take Quiz',
                style: GoogleFonts.outfit(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizView(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mini Quiz',
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Obx(
            () => Text(
              'Question ${controller.quizQuestionIndex.value + 1}/${controller.quizQuestions.length}',
              style: GoogleFonts.inter(
                color: Colors.grey[600],
                fontSize: 14.sp,
              ),
            ),
          ),
          SizedBox(height: 32.h),

          Obx(() {
            final question =
                controller.quizQuestions[controller.quizQuestionIndex.value];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question['question'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 24.h),
                ...(question['options'] as List<String>).asMap().entries.map((
                  entry,
                ) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          HapticUtils.selectionClick();
                          controller.answerQuiz(entry.key);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.all(16.r),
                          alignment: Alignment.centerLeft,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          entry.value,
                          style: GoogleFonts.inter(
                            color: Colors.black87,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }
}

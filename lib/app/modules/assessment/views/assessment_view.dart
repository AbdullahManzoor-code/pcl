import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/assessment_controller.dart';

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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar
              Obx(
                () => LinearProgressIndicator(
                  value:
                      (controller.currentQuestionIndex.value + 1) /
                      controller.questions.length,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Question Counter
              Obx(
                () => Text(
                  'Question ${controller.currentQuestionIndex.value + 1}/${controller.questions.length}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Question Text
              Obx(
                () => Text(
                  controller.questions[controller
                          .currentQuestionIndex
                          .value]['question']
                      as String,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Options
              Expanded(
                child: Obx(() {
                  final currentQIndex = controller.currentQuestionIndex.value;
                  final options =
                      controller.questions[currentQIndex]['options']
                          as List<String>;
                  final selectedAnswer = controller.answers[currentQIndex];

                  return ListView.separated(
                    itemCount: options.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final isSelected = selectedAnswer == index;
                      return InkWell(
                        onTap: () =>
                            controller.selectAnswer(currentQIndex, index),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : null,
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  options[index],
                                  style: TextStyle(
                                    fontSize: 16,
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
                            onPressed: controller.previousQuestion,
                            child: const Text('Previous'),
                          )
                        : const SizedBox.shrink(),
                  ),
                  Obx(
                    () => ElevatedButton(
                      onPressed:
                          controller.answers.containsKey(
                            controller.currentQuestionIndex.value,
                          )
                          ? controller.nextQuestion
                          : null, // Disable if not answered? Or allow skip? User functional flow says "submit test", implies mandatory? Let's assume selection required.
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        controller.currentQuestionIndex.value ==
                                controller.questions.length - 1
                            ? 'Submit'
                            : 'Next',
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

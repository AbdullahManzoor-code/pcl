import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/learning_controller.dart';
import '../../../core/widgets/app_code_editor.dart';

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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Topic Banner (Mock Image)
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.image,
                        size: 80,
                        color: Colors.blue.shade300,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Content Text (Simplified rendering)
                  Text(
                    controller.content,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),

                  if (controller.topic['code'] != null) ...[
                    const SizedBox(height: 24),
                    AppCodeEditor(
                      code: controller.topic['code'],
                      language: controller.topic['language'] ?? 'dart',
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.startQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Differentiate typical action
              ),
              child: const Text('Take Quiz'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mini Quiz',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              'Question ${controller.quizQuestionIndex.value + 1}/${controller.quizQuestions.length}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 32),

          Obx(() {
            final question =
                controller.quizQuestions[controller.quizQuestionIndex.value];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question['question'] as String,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                ...(question['options'] as List<String>).asMap().entries.map((
                  entry,
                ) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => controller.answerQuiz(entry.key),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          alignment: Alignment.centerLeft,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          entry.value,
                          style: const TextStyle(color: Colors.black87),
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

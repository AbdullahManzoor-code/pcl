import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/quiz_controller.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';

class QuizView extends GetView<QuizController> {
  const QuizView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.isFinished.value ? 'Quiz Results' : 'Course Test',
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.quiz.value == null) {
          return const Center(
            child: Text('No quiz available for this course.'),
          );
        }

        if (controller.isFinished.value) {
          return _buildResults(context);
        }

        return _buildQuizContent(context);
      }),
    );
  }

  Widget _buildQuizContent(BuildContext context) {
    final question =
        controller.quiz.value!.questions[controller.currentIndex.value];
    final total = controller.quiz.value!.questions.length;
    final progress = (controller.currentIndex.value + 1) / total;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress Indicator
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${controller.currentIndex.value + 1} of $total',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Question Text
          Text(
            question.text,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 32),

          // Options
          ...List.generate(
            question.options.length,
            (index) =>
                _buildOptionCard(context, index, question.options[index]),
          ),

          const SizedBox(height: 40),

          // Next Button
          AppButton(
            text: controller.currentIndex.value == total - 1
                ? 'Finish Quiz'
                : 'Next Question',
            onPressed: controller.selectedOption.value != null
                ? () => controller.nextQuestion()
                : () {},
            isLoading: false,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, int index, String text) {
    final isSelected = controller.selectedOption.value == index;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: AppCard(
        onTap: () => controller.selectOption(index),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: isSelected ? Border.all(color: colorScheme.primary) : null,
        color: isSelected
            ? colorScheme.primaryContainer.withOpacity(0.3)
            : colorScheme.surface,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colorScheme.primary, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    final score = controller.score.value;
    final total = controller.quiz.value!.questions.length;
    final percentage = (score / total) * 100;
    final passed = percentage >= 60;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              passed
                  ? Icons.emoji_events_rounded
                  : Icons.sentiment_very_dissatisfied_rounded,
              size: 100,
              color: passed
                  ? Colors.amber
                  : Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              passed ? 'Congratulations!' : 'Keep Practicing!',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              passed
                  ? 'You have successfully completed the course test.'
                  : 'You didn\'t pass this time. Review the course and try again.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 40),
            AppCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Your Score',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$score / $total',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: passed ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${percentage.toInt()}%',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.restartQuiz(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Try Again'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppButton(
                    text: 'Finish',
                    onPressed: () => Get.back(),
                    isLoading: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

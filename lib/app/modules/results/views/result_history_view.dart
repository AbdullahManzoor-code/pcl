import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/result_history_controller.dart';
import '../../../routes/app_pages.dart';
import 'package:intl/intl.dart';

class ResultHistoryView extends GetView<ResultHistoryController> {
  const ResultHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(ResultHistoryController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Exam History',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.history.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: theme.disabledColor),
                const SizedBox(height: 16),
                Text(
                  'No past exams found.',
                  style: GoogleFonts.inter(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: controller.history.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = controller.history[index];
            final scoreColor = item.overallScore >= 0.7 
              ? Colors.green 
              : (item.overallScore >= 0.5 ? Colors.orange : Colors.red);
              
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Get.toNamed(Routes.results, arguments: item.sessionId);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scoreColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${(item.overallScore * 100).toInt()}%',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.topicName.isNotEmpty ? item.topicName : item.majorTopicId,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM d, yyyy • h:mm a').format(item.createdAt.toLocal()),
                            style: GoogleFonts.inter(
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: theme.iconTheme.color?.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/reports_controller.dart';
import '../../../core/widgets/next_components.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/widgets/shimmer_widgets.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildForm(context),
            const SizedBox(height: 12),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report a Question',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Question ID (paste)',
              ),
              controller: TextEditingController(
                text: controller.questionId.value,
              ),
              onChanged: (v) => controller.questionId.value = v.trim().isEmpty
                  ? null
                  : v.trim(),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: controller.reportType.value,
              items: const [
                DropdownMenuItem(
                  value: 'incorrect_answer',
                  child: Text('Incorrect Answer'),
                ),
                DropdownMenuItem(
                  value: 'missing_correct',
                  child: Text('Missing Correct'),
                ),
                DropdownMenuItem(
                  value: 'confusing_wording',
                  child: Text('Confusing Wording'),
                ),
                DropdownMenuItem(
                  value: 'explanation_mismatch',
                  child: Text('Explanation Mismatch'),
                ),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (v) => controller.reportType.value = v ?? 'other',
            ),
            const SizedBox(height: 8),
            TextField(
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Description (min 10 chars)',
              ),
              onChanged: (v) => controller.description.value = v,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: NextButton(
                text: 'Submit Report',
                onPressed: controller.isLoading.value
                    ? null
                    : () async {
                        // For simplicity, require question id in the questionId field here
                        final qid = controller.questionId.value;
                        if (qid == null || qid.isEmpty) {
                          Get.snackbar(
                            'Missing Question',
                            'Please enter the Question ID to report.',
                          );
                          return;
                        }
                        if (controller.description.value.trim().length < 10) {
                          Get.snackbar(
                            'Description too short',
                            'Please provide at least 10 characters',
                          );
                          return;
                        }
                        await controller.submitReport(qid);
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return Obx(() {
      if (controller.isLoading.value && controller.reports.isEmpty) {
        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.r),
          itemCount: 5,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (_, __) => ShimmerBox(width: double.infinity, height: 70.h, borderRadius: 12),
        );
      }
      if (controller.reports.isEmpty) {
        return const Center(child: Text('No reports yet'));
      }
      return ListView.separated(
        itemCount: controller.reports.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, idx) {
          final r = controller.reports[idx];
          return ListTile(
            title: Text(r.reportType),
            subtitle: Text(r.description),
            trailing: Text(r.status),
          );
        },
      );
    });
  }
}

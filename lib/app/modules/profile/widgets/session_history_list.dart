import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/utils/datetime_utils.dart';
import 'package:pcl/app/core/theme/app_theme.dart';
import 'package:pcl/app/data/models/exam_api_models.dart';

class SessionHistoryList extends StatelessWidget {
  final List<SessionHistoryItem> sessions;

  const SessionHistoryList({Key? key, required this.sessions})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('No session history found.'),
        ),
      );
    }

    return ListView.builder(
      itemCount: sessions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final session = sessions[index];
        return _buildSessionHistoryItem(session);
      },
    );
  }

  Widget _buildSessionHistoryItem(SessionHistoryItem session) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      child: ListTile(
        leading: Icon(
          _getIconForSessionType(session.sessionType),
          color: AppColors.primary,
        ),
        title: Text(
          session.topicName ?? 'General Practice',
          style: Get.textTheme.titleSmall,
        ),
        subtitle: Text(
          'Score: ${(session.overallScore * 100).toStringAsFixed(0)}% • ${DateTimeUtils.formatDate(session.completedAt)}',
        ),
        trailing: Text(
          session.sessionType.capitalizeFirst ?? '',
          style: Get.textTheme.bodySmall?.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }

  IconData _getIconForSessionType(String type) {
    switch (type.toLowerCase()) {
      case 'exam':
        return Icons.quiz;
      case 'practice':
        return Icons.lightbulb;
      case 'review':
        return Icons.replay;
      default:
        return Icons.history;
    }
  }
}

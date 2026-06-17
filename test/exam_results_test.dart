import 'package:flutter_test/flutter_test.dart';
import 'package:pcl/app/data/models/exam_api_models.dart';

void main() {
  group('Exam Results Parsing Tests', () {
    test('SessionHistoryItem parses correctly from JSON', () {
      final json = {
        'session_id': 'sess_123',
        'session_type': 'exam',
        'language_id': 'python_3',
        'major_topic_id': 'variables',
        'topic_name': 'Variables',
        'overall_score': 0.85,
        'accuracy': 0.85,
        'difficulty': 0.5,
        'time_taken_seconds': 120,
        'created_at': '2023-01-01T10:00:00.000Z',
        'completed_at': '2023-01-01T10:02:00.000Z',
        'question_count': 10,
        'correct_count': 8,
      };

      final item = SessionHistoryItem.fromJson(json);

      expect(item.sessionId, 'sess_123');
      expect(item.sessionType, 'exam');
      expect(item.languageId, 'python_3');
      expect(item.majorTopicId, 'variables');
      expect(item.topicName, 'Variables');
      expect(item.overallScore, 0.85);
      expect(item.accuracy, 0.85);
      expect(item.difficulty, 0.5);
      expect(item.timeTakenSeconds, 120);
      expect(item.questionCount, 10);
      expect(item.correctCount, 8);
    });

    test('SessionHistoryResponse parses correctly from JSON', () {
      final json = {
        'sessions': [
          {
            'session_id': 'sess_123',
            'session_type': 'exam',
            'language_id': 'python_3',
            'major_topic_id': 'variables',
            'topic_name': 'Variables',
            'overall_score': 0.85,
            'accuracy': 0.85,
            'difficulty': 0.5,
            'time_taken_seconds': 120,
            'created_at': '2023-01-01T10:00:00.000Z',
            'completed_at': '2023-01-01T10:02:00.000Z',
            'question_count': 10,
            'correct_count': 8,
          }
        ],
        'total_count': 1,
        'limit': 10,
        'offset': 0,
      };

      final response = SessionHistoryResponse.fromJson(json);

      expect(response.totalCount, 1);
      expect(response.sessions.length, 1);
      expect(response.sessions.first.sessionId, 'sess_123');
    });
  });
}

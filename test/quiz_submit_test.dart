import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:pcl/app/modules/quiz/controllers/quiz_controller.dart';
import 'package:pcl/app/data/models/exam_api_models.dart';
import 'package:pcl/app/data/models/user_model.dart';
import 'package:pcl/app/data/services/exam_service.dart';
import 'package:pcl/app/data/services/auth_service.dart';
import 'package:pcl/app/data/services/api_adapter_service.dart';

/// Minimal mock ExamService that captures the payload passed to submitExam
class MockExamService extends ExamService {
  ExamSubmissionPayload? capturedPayload;

  @override
  Future<ExamSubmissionResponse> submitExam(
    ExamSubmissionPayload payload,
  ) async {
    capturedPayload = payload;
    // Return a minimal valid response
    return ExamSubmissionResponse(
      success: true,
      sessionId: payload.sessionId,
      accuracy: 0.8,
      fluencyRatio: 0.9,
      newMasteryScore: 0.0,
      recommendations: [],
    );
  }
}

/// Minimal mock AuthService that returns a fixed user id
class MockAuthService extends AuthService {
  @override
  Future<User> getMe() async {
    return User(
      id: 'a67817d3-cb7d-4147-9b65-bf15605d3a45',
      email: 'test@example.com',
    );
  }

  @override
  User? getStoredUser() {
    return User(
      id: 'a67817d3-cb7d-4147-9b65-bf15605d3a45',
      email: 'test@example.com',
    );
  }

  @override
  String? getAccessToken() => 'mock-token';
}

void main() {
  test(
    'QuizController.submitQuiz() builds valid payload and calls ExamService',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      // Provide a mock implementation for path_provider used by GetStorage
      const pathProviderChannel = MethodChannel(
        'plugins.flutter.io/path_provider',
      );
      pathProviderChannel.setMockMethodCallHandler((MethodCall method) async {
        return Directory.systemTemp.path;
      });
      await GetStorage.init();

      // Reset global state
      Get.reset();
      // Enable Get test mode to avoid needing a GetMaterialApp for navigation/snackbar
      Get.testMode = true;

      // Register required adapter and mocks
      Get.put<ApiAdapterService>(ApiAdapterService());
      final mockAuth = MockAuthService();
      Get.put<AuthService>(mockAuth);
      final mockExam = MockExamService();
      Get.put<ExamService>(mockExam);

      // Create controller after mocks are registered
      final controller = QuizController();

      // Prepare 5 sample questions
      final options = [
        QuestionOption(id: 'o1', text: 'One', isCorrect: true),
        QuestionOption(id: 'o2', text: 'Two', isCorrect: false),
        QuestionOption(id: 'o3', text: 'Three', isCorrect: false),
        QuestionOption(id: 'o4', text: 'Four', isCorrect: false),
      ];

      for (int i = 0; i < 5; i++) {
        final qd = QuestionData(questionText: 'Q$i', options: options);
        final sq = SelectedQuestion(
          id: 'q-$i',
          questionData: qd,
          difficulty: 0.5,
          qualityScore: 0.5,
          isVerified: true,
          mappingId: 'map',
          languageId: 'go_1_21',
          subTopic: 'GO_OOP_01',
        );
        controller.questions.add(sq);
      }

      // Fill answers map with some picks (index 0..3)
      for (int i = 0; i < 5; i++) {
        controller.answers[i] = 0; // select first option (A)
      }

      controller.courseId = 'go_1_21';
      controller.topicId = 'GO_OOP_01';
      controller.sessionId = 'session-123';
      controller.startTime = DateTime.now().subtract(
        const Duration(seconds: 300),
      );

      // Call submitQuiz
      await controller.submitQuiz();

      // Ensure mock captured payload and print it
      final captured = mockExam.capturedPayload;
      expect(captured, isNotNull);
      print('Captured payload JSON: ${captured?.toSubmitJson()}');

      // Basic assertions
      expect(captured?.results.length, 5);
      expect(captured?.totalTimeSeconds, greaterThan(0));
      expect(captured?.userId, 'a67817d3-cb7d-4147-9b65-bf15605d3a45');
    },
  );
}

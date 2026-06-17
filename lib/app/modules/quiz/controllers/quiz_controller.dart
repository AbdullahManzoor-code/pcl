import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/models/exam_api_models.dart';
import '../../../data/services/exam_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../../../core/widgets/celebration.dart';

class QuizController extends GetxController with WidgetsBindingObserver {
  static const int _minimumSubmitQuestions = 5;

  // Public accessor for UI to read the minimum submit requirement
  int get minSubmitQuestions => _minimumSubmitQuestions;

  final ExamService _examService = Get.find<ExamService>();
  final AuthService _authService = Get.find<AuthService>();
  final GetStorage _storage = GetStorage();

  final questions = <SelectedQuestion>[].obs;
  final currentIndex = 0.obs;
  final answers = <int, dynamic>{}.obs;
  final timeLeft = 1800.obs; // 30 mins default
  final isLoading = true.obs;
  final isDiagnostic = false.obs;

  String courseId = '';
  String topicId = '';
  int numQuestions = 10;
  String sessionId = '';
  DateTime? startTime;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('QuizController.onInit(): attaching lifecycle observer');
    WidgetsBinding.instance.addObserver(this);
    final args = Get.arguments;
    if (args != null) {
      if (args is Map<String, dynamic>) {
        courseId = args['courseId'] ?? '';
        topicId = args['topicId'] ?? courseId;
        numQuestions = args['numQuestions'] ?? 10;
        isDiagnostic.value = args['isDiagnostic'] ?? false;
      } else if (args is String) {
        courseId = args;
        topicId = args;
      }
      if (numQuestions < _minimumSubmitQuestions) {
        AppLogger.warning(
          'QuizController.onInit(): requested numQuestions=$numQuestions is below backend minimum; clamping to $_minimumSubmitQuestions',
        );
        numQuestions = _minimumSubmitQuestions;
      }
      AppLogger.info(
        'QuizController.onInit(): courseId=$courseId, topicId=$topicId, numQuestions=$numQuestions, diagnostic=${isDiagnostic.value}',
      );
      _initializeExam();
    } else {
      AppLogger.warning(
        'QuizController.onInit(): missing arguments, returning',
      );
      Get.back();
    }
  }

  @override
  void onClose() {
    AppLogger.info('QuizController.onClose(): disposing quiz session');
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    AppLogger.debug(
      'QuizController.didChangeAppLifecycleState(): state=$state',
    );
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // App pushed to background or inactive -> save state and pause timer
      _saveBackup();
      _timer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      // App came back to foreground -> resume timer if not finished
      if (timeLeft.value > 0 && !isLoading.value) {
        startTimer();
      }
    }
  }

  Future<void> _initializeExam() async {
    AppLogger.info('QuizController._initializeExam(): start');
    isLoading.value = true;
    try {
      String? userId = _authService.getStoredUser()?.id;
      userId ??= _storage.read('userId') as String?;

      // Try to refresh/verify auth state and get a definitive user id.
      try {
        final me = await _authService.getMe();
        userId ??= me.id;
      } catch (e, stackTrace) {
        AppLogger.warning(
          'QuizController._initializeExam(): getMe failed, attempting session restore',
          e,
          stackTrace,
        );

        final restored = await _authService.restoreSession();
        if (restored) {
          try {
            final me = await _authService.getMe();
            userId ??= me.id;
          } catch (innerError, innerStackTrace) {
            AppLogger.warning(
              'QuizController._initializeExam(): getMe failed after restore',
              innerError,
              innerStackTrace,
            );
          }
        }
      }

      if (userId == null || userId.isEmpty) {
        AppLogger.warning(
          'QuizController._initializeExam(): session expired, redirecting to auth',
        );
        Get.snackbar(
          'Session Expired',
          'Please log in again to start the quiz.',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offAllNamed(Routes.auth);
        return;
      }

      final backupKey = 'exam_backup_${courseId}_$topicId';

      // Check for backup
      final backup = _storage.read(backupKey);
      if (backup != null && backup['sessionId'] != null) {
        AppLogger.info(
          'QuizController._initializeExam(): restoring backup for $backupKey',
        );
        // Resume session
        sessionId = backup['sessionId'];
        timeLeft.value = backup['timeLeft'] ?? 1800;
        final savedAnswers = backup['answers'] as Map<String, dynamic>?;
        if (savedAnswers != null) {
          savedAnswers.forEach((key, value) {
            answers[int.parse(key)] = value;
          });
        }

        // We still need the questions, ideally we'd cache them too,
        // but for now we fetch new ones if we don't have them in cache.
        final cachedQuestions = _storage.read('${backupKey}_questions');
        if (cachedQuestions != null) {
          questions.assignAll(
            (cachedQuestions as List)
                .map((q) => SelectedQuestion.fromJson(q))
                .toList(),
          );
        }

        if (questions.isNotEmpty && timeLeft.value > 0) {
          startTime ??= DateTime.now().subtract(
            Duration(seconds: (questions.length * 90) - timeLeft.value),
          );
        }
      }

      if (questions.isEmpty) {
        // Start fresh
        AppLogger.info(
          'QuizController._initializeExam(): starting fresh exam session',
        );
        final startReq = ExamStartRequest(
          userId: userId,
          languageId: courseId,
          majorTopicId: topicId,
          sessionType: isDiagnostic.value ? 'diagnostic' : 'practice',
        );
        final startRes = await _examService.startExamSession(startReq);
        sessionId = startRes.sessionId;
        startTime = startRes.startedAt;

        final selectReq = SelectQuestionsRequest(
          userId: userId,
          sessionId: sessionId,
          languageId: courseId,
          mappingId: topicId,
          targetDifficulty: 0.5,
          count: numQuestions,
          mode: isDiagnostic.value ? 'review' : 'practice',
        );
        final selectRes = await _examService.selectQuestions(selectReq);
        questions.assignAll(selectRes.questions);

        if (questions.isEmpty || selectRes.moreQuestionsLoading) {
          AppLogger.warning(
            'QuizController._initializeExam(): initial question selection empty; polling for generated questions (sessionId=$sessionId)',
          );
          for (int attempt = 0; attempt < 5 && questions.isEmpty; attempt++) {
            await Future.delayed(const Duration(seconds: 2));
            final pollRes = await _examService.pollNewQuestions(sessionId);
            if (pollRes.questions.isNotEmpty) {
              questions.assignAll(pollRes.questions);
              AppLogger.info(
                'QuizController._initializeExam(): poll attempt ${attempt + 1} loaded ${pollRes.questions.length} questions',
              );
              break;
            }
          }
        }

        if (questions.length < _minimumSubmitQuestions) {
          throw Exception(
            'At least $_minimumSubmitQuestions questions are required to start the exam.',
          );
        }

        // Pre-cache media
        if (Get.context != null) {
          for (var q in questions) {
            if (q.questionData.mediaUrl != null) {
              try {
                await precacheImage(
                  NetworkImage(q.questionData.mediaUrl!),
                  Get.context!,
                );
              } catch (e, stackTrace) {
                AppLogger.warning(
                  'QuizController._initializeExam(): failed to precache image',
                  e,
                  stackTrace,
                );
              }
            }
          }
        }

        if (questions.isEmpty) {
          throw Exception('No questions available for this session yet.');
        }

        timeLeft.value = questions.length * 90;

        // Save initial backup
        _storage.write(
          '${backupKey}_questions',
          questions.map((q) => q.toJson()).toList(),
        );
        _storage.remove(backupKey);
      }

      startTimer();
    } catch (e, stackTrace) {
      AppLogger.error(
        'QuizController._initializeExam(): failed',
        e,
        stackTrace,
      );
      Get.snackbar('Error', 'Failed to start exam session.');
    } finally {
      isLoading.value = false;
    }
  }

  void startTimer() {
    AppLogger.debug('QuizController.startTimer(): starting countdown');
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft.value > 0) {
        timeLeft.value--;
        if (timeLeft.value % 10 == 0) _saveBackup(); // Backup every 10s
      } else {
        submitQuiz();
        timer.cancel();
      }
    });
  }

  void _saveBackup() {
    AppLogger.debug('QuizController._saveBackup(): saving progress backup');
    final backupKey = 'exam_backup_${courseId}_$topicId';
    _storage.write(backupKey, {
      'sessionId': sessionId,
      'timeLeft': timeLeft.value,
      'answers': answers.map((key, value) => MapEntry(key.toString(), value)),
    });
  }

  void selectOption(int answerIndex) {
    AppLogger.info(
      'QuizController.selectOption(): index=$answerIndex, question=${currentIndex.value}',
    );
    answers[currentIndex.value] = answerIndex;
    _saveBackup();
  }

  void nextQuestion() {
    if (currentIndex.value < questions.length - 1) {
      AppLogger.debug(
        'QuizController.nextQuestion(): moving to ${currentIndex.value + 1}',
      );
      currentIndex.value++;
    }
  }

  void prevQuestion() {
    if (currentIndex.value > 0) {
      AppLogger.debug(
        'QuizController.prevQuestion(): moving to ${currentIndex.value - 1}',
      );
      currentIndex.value--;
    }
  }

  void jumpToQuestion(int index) {
    AppLogger.debug('QuizController.jumpToQuestion(): index=$index');
    currentIndex.value = index;
  }

  Future<void> submitQuiz() async {
    AppLogger.info('QuizController.submitQuiz(): submitting exam');
    _timer?.cancel();
    isLoading.value = true;

    try {
      if (questions.length < _minimumSubmitQuestions) {
        AppLogger.warning(
          'QuizController.submitQuiz(): aborting submit - insufficient questions (count=${questions.length})',
        );
        Get.snackbar(
          'Cannot Submit',
          'At least $_minimumSubmitQuestions questions are required before submitting.',
          snackPosition: SnackPosition.BOTTOM,
        );
        isLoading.value = false;
        return;
      }

      String userId = 'guest';
      try {
        final user = await _authService.getMe();
        userId = user.id!;
      } catch (_) {}
      final results = <QuestionResultPayload>[];
      const choiceLabels = ['A', 'B', 'C', 'D'];

      // Compute total elapsed time robustly. Prefer authoritative startTime if available.
      int elapsedSeconds = 0;
      if (startTime != null) {
        elapsedSeconds = DateTime.now().difference(startTime!).inSeconds;
      } else {
        elapsedSeconds = (questions.length * 90) - timeLeft.value;
      }
      elapsedSeconds = elapsedSeconds < 1 ? 1 : elapsedSeconds;

      // Distribute timeSpent per question reasonably (at least 1s each)
      final perQuestion = (elapsedSeconds / questions.length).ceil();

      for (int i = 0; i < questions.length; i++) {
        final q = questions[i];
        final userAnswerIndex = answers[i];

        String selectedChoice = '';
        bool isCorrect = false;
        String correctChoice = '';

        // Find correct choice
        for (
          int optionIndex = 0;
          optionIndex < q.questionData.options.length;
          optionIndex++
        ) {
          if (q.questionData.options[optionIndex].isCorrect) {
            correctChoice = choiceLabels[optionIndex];
            break;
          }
        }

        if (userAnswerIndex != null) {
          if (userAnswerIndex is int &&
              userAnswerIndex < q.questionData.options.length) {
            selectedChoice = choiceLabels[userAnswerIndex];
            isCorrect = q.questionData.options[userAnswerIndex].isCorrect;
          } else if (userAnswerIndex is String) {
            final normalizedChoice = userAnswerIndex.trim().toUpperCase();
            if (choiceLabels.contains(normalizedChoice)) {
              selectedChoice = normalizedChoice;
              isCorrect = selectedChoice == correctChoice;
            }
          }
        }

        results.add(
          QuestionResultPayload(
            qId: q.id,
            subTopic: q.subTopic ?? topicId,
            difficulty: q.difficulty,
            isCorrect: isCorrect,
            selectedChoice: selectedChoice,
            correctChoice: correctChoice,
            timeSpent: perQuestion,
            expectedTime: 90,
            questionText: q.questionData.questionText,
            options: q.questionData.options,
          ),
        );
      }

      final payload = ExamSubmissionPayload(
        userId: userId,
        sessionId: sessionId,
        languageId: courseId,
        majorTopicId: topicId,
        sessionType: isDiagnostic.value ? 'diagnostic' : 'practice',
        results: results,
        totalTimeSeconds: elapsedSeconds,
      );

      // Validate before submitting to avoid server 422s
      if (payload.results.isEmpty || payload.results.length < 5) {
        AppLogger.warning(
          'QuizController.submitQuiz(): aborting submit - insufficient results (count=${payload.results.length})',
        );
        Get.snackbar(
          'Cannot Submit',
          'Not enough answered questions to submit the exam.',
          snackPosition: SnackPosition.BOTTOM,
        );
        isLoading.value = false;
        return;
      }

      if (payload.totalTimeSeconds <= 0) {
        AppLogger.warning(
          'QuizController.submitQuiz(): aborting submit - invalid totalTimeSeconds=${payload.totalTimeSeconds}',
        );
        Get.snackbar(
          'Cannot Submit',
          'Invalid exam time recorded. Try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
        isLoading.value = false;
        return;
      }

      final response = await _examService.submitExam(payload);
      AppLogger.info(
        'QuizController.submitQuiz(): submission complete newMastery=${response.newMasteryScore}',
      );

      // Clear backup
      _storage.remove('exam_backup_${courseId}_$topicId');

      if (response.newMasteryScore > 0) {
        LevelUpOverlay.show(
          (response.newMasteryScore * 100).toInt(),
        ); // Mock level
        await Future.delayed(const Duration(seconds: 1));
      }

      // Pass the session ID to the results view
      Get.offNamed(Routes.results, arguments: sessionId);
    } catch (e, stackTrace) {
      AppLogger.error('QuizController.submitQuiz(): failed', e, stackTrace);
      Get.snackbar(
        'Error',
        'Failed to submit exam. Results are saved locally.',
      );
      isLoading.value = false;
    }
  }

  String get formattedTime {
    final mins = (timeLeft.value / 60).floor().toString().padLeft(2, '0');
    final secs = (timeLeft.value % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }
}

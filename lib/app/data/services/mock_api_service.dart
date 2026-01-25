import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:math';

class MockApiService extends GetxService {
  final _storage = GetStorage();

  static const String _USER_KEY = 'user_data';
  static const String _COURSES_KEY = 'courses_data';
  static const String _EVAL_KEY = 'ml_evaluation';

  final lastEvaluation = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  void _loadData() {
    final storedUser = _storage.read(_USER_KEY);
    if (storedUser != null) {
      _user.value = Map<String, dynamic>.from(storedUser);
    }

    final storedCourses = _storage.read(_COURSES_KEY);
    if (storedCourses != null) {
      courses.assignAll(
        List<Map<String, dynamic>>.from(
          (storedCourses as List).map(
            (e) => Map<String, dynamic>.from(e as Map),
          ),
        ).toList(),
      );
    }

    final storedEval = _storage.read(_EVAL_KEY);
    if (storedEval != null) {
      lastEvaluation.assignAll(Map<String, dynamic>.from(storedEval));
    }
  }

  void _saveUser() => _storage.write(_USER_KEY, _user);
  void _saveCourses() => _storage.write(_COURSES_KEY, courses);
  void _saveEval() => _storage.write(_EVAL_KEY, lastEvaluation);

  // Mock User Data - Matched to Next.js Dashboard
  final RxMap<String, dynamic> _user = <String, dynamic>{
    'name': 'Mian',
    'email': 'mian@example.com',
    'profile_pic': null, // Will use default avatar
    'bio': 'Passionate coder and Flutter enthusiast.',
    'stats': {
      'consecutive_days': 15, // Matches Next.js 'Current Streak'
      'total_hours': 30, // Arbitrary
      'completed_courses': 2,
      'total_xp': 12500,
      'today_points': 8,
      'today_minutes': 12,
    },
  }.obs;

  // Mock Courses Data - Matched to Next.js 'My Learning Paths'
  final RxList<Map<String, dynamic>> courses = <Map<String, dynamic>>[
    {
      'id': 'python_3',
      'title': 'Python',
      'category': 'Language',
      'level': 'Medium',
      'difficulty': 0.5,
      'image': 'assets/images/python.png',
      'progress': 0.0,
      'is_completed': false,
      'is_enrolled': true,
      'rating': 4.8,
      'review_count': 120,
      'description': 'Master Python programming language.',
      'accuracy': 0,
      'topics_completed': 0,
      'total_topics': 8,
    },
    {
      'id': 'javascript_es6',
      'title': 'JavaScript',
      'category': 'Language',
      'level': 'Hard',
      'difficulty': 0.8,
      'image': 'assets/images/js.png',
      'progress': 0.75,
      'is_completed': false,
      'is_enrolled': true,
      'rating': 4.5,
      'review_count': 890,
      'description': 'Modern JavaScript development.',
      'accuracy': 82,
      'topics_completed': 6,
      'total_topics': 8,
    },
    {
      'id': 'cpp_20',
      'title': 'C++',
      'category': 'Language',
      'level': 'Hard',
      'difficulty': 0.9,
      'image': 'assets/images/cpp.png',
      'progress': 0.35,
      'is_completed': false,
      'is_enrolled': true,
      'rating': 4.9,
      'review_count': 500,
      'description': 'High performance C++ programming.',
      'accuracy': 65,
      'topics_completed': 3,
      'total_topics': 8,
    },
    {
      'id': 'java_17',
      'title': 'Java',
      'category': 'Language',
      'level': 'Easy',
      'difficulty': 0.3,
      'image': 'assets/images/java.png',
      'progress': 0.1,
      'is_completed': false,
      'is_enrolled': false,
      'rating': 4.6,
      'review_count': 1500,
      'description': 'Enterprise Java development.',
      'accuracy': 90,
      'topics_completed': 1,
      'total_topics': 8,
    },
  ].obs;

  // Mock Quizzes for each course (5 MCQs each)
  final Map<String, List<Map<String, dynamic>>> _courseQuizzes = {
    'python_3': [
      {
        'id': 'q1_1',
        'question': 'What is the correct way to create a list in Python?',
        'options': ['list = []', 'list = {}', 'list = ()', 'list = <>'],
        'correctAnswer': 0,
      },
      {
        'id': 'q1_2',
        'question': 'Which keyword is used to define a function in Python?',
        'options': ['func', 'define', 'def', 'function'],
        'correctAnswer': 2,
      },
      {
        'id': 'q1_3',
        'question': 'How do you insert a comment in Python code?',
        'options': ['//', '/*', '#', '--'],
        'correctAnswer': 2,
      },
      {
        'id': 'q1_4',
        'question':
            'Which data type is used to store multiple items in a single variable where order is preserved and change is allowed?',
        'options': ['Set', 'Tuple', 'Dictionary', 'List'],
        'correctAnswer': 3,
      },
      {
        'id': 'q1_5',
        'question': 'What is the output of print(2 ** 3)?',
        'options': ['5', '6', '8', '9'],
        'correctAnswer': 2,
      },
    ],
    'javascript_es6': [
      {
        'id': 'q2_1',
        'question': 'What is the output of "2" + 2 in JavaScript?',
        'options': ['4', '"22"', 'NaN', 'Error'],
        'correctAnswer': 1,
      },
      {
        'id': 'q2_2',
        'question': 'Which keyword is used to declare a constant in ES6?',
        'options': ['var', 'let', 'const', 'constant'],
        'correctAnswer': 2,
      },
      {
        'id': 'q2_3',
        'question': 'What does DOM stand for?',
        'options': [
          'Data Object Model',
          'Document Object Model',
          'Digital Object Model',
          'None',
        ],
        'correctAnswer': 1,
      },
      {
        'id': 'q2_4',
        'question': 'Which of these is NOT a JS data type?',
        'options': ['Boolean', 'Undefined', 'Float', 'Symbol'],
        'correctAnswer': 2,
      },
      {
        'id': 'q2_5',
        'question': 'What is the use of "use strict";?',
        'options': [
          'Makes code faster',
          'Enforces strict parsing',
          'Debug mode',
          'None',
        ],
        'correctAnswer': 1,
      },
    ],
    'cpp_20': [
      {
        'id': 'q3_1',
        'question': 'Which header is used for input/output in C++?',
        'options': ['<stdio.h>', '<iostream>', '<conio.h>', '<math.h>'],
        'correctAnswer': 1,
      },
      {
        'id': 'q3_2',
        'question': 'What is the size of int in C++ (usually)?',
        'options': ['2 bytes', '4 bytes', '8 bytes', 'Depends on system'],
        'correctAnswer': 1,
      },
      {
        'id': 'q3_3',
        'question':
            'Which operator is used to access the address of a variable?',
        'options': ['*', '&', '->', '.'],
        'correctAnswer': 1,
      },
      {
        'id': 'q3_4',
        'question': 'What is a pointer?',
        'options': [
          'A variable that holds an image',
          'A variable that holds an address',
          'An arrow',
          'None',
        ],
        'correctAnswer': 1,
      },
      {
        'id': 'q3_5',
        'question': 'Who developed C++?',
        'options': [
          'Guido van Rossum',
          'Bjarne Stroustrup',
          'James Gosling',
          'Dennis Ritchie',
        ],
        'correctAnswer': 1,
      },
    ],
    'java_17': [
      {
        'id': 'q4_1',
        'question': 'What is the entry point of a Java program?',
        'options': ['start()', 'main()', 'init()', 'run()'],
        'correctAnswer': 1,
      },
      {
        'id': 'q4_2',
        'question': 'Which keyword is used to inherit a class in Java?',
        'options': ['implements', 'extends', 'inherits', 'import'],
        'correctAnswer': 1,
      },
      {
        'id': 'q4_3',
        'question': 'What is JVM?',
        'options': [
          'Java Visual Machine',
          'Java Virtual Machine',
          'Java Video Machine',
          'None',
        ],
        'correctAnswer': 1,
      },
      {
        'id': 'q4_4',
        'question': 'Which data type is used for long decimals?',
        'options': ['float', 'double', 'decimal', 'long'],
        'correctAnswer': 1,
      },
      {
        'id': 'q4_5',
        'question': 'Is Java platform independent?',
        'options': ['No', 'Yes', 'Depends', 'Only on Linux'],
        'correctAnswer': 1,
      },
    ],
  };

  final Map<String, List<Map<String, dynamic>>> _diagnosticQuizzes = {
    'python_3': [
      {
        'id': 'd_py_1',
        'question': 'What is the output of print(type([])) in Python?',
        'options': [
          "<class 'list'>",
          "<class 'tuple'>",
          "<class 'dict'>",
          "<class 'array'>",
        ],
        'correctAnswer': 0,
      },
      {
        'id': 'd_py_2',
        'question': 'Which of these is a valid variable name in Python?',
        'options': ['2variable', '_variable', 'variable-name', 'variable name'],
        'correctAnswer': 1,
      },
    ],
    'javascript_es6': [
      {
        'id': 'd_js_1',
        'question':
            'Which keyword is used to declare a block-scoped variable in modern JS?',
        'options': ['var', 'let', 'set', 'dim'],
        'correctAnswer': 1,
      },
      {
        'id': 'd_js_2',
        'question': 'What is the result of "2" + 2 in JavaScript?',
        'options': ['4', '"22"', 'NaN', 'Error'],
        'correctAnswer': 1,
      },
    ],
    'cpp_20': [
      {
        'id': 'd_cpp_1',
        'question': 'Which symbol is used for comments in C++?',
        'options': ['#', '--', '//', '/*'],
        'correctAnswer': 2,
      },
      {
        'id': 'd_cpp_2',
        'question': 'Is C++ a case-sensitive language?',
        'options': ['Yes', 'No', 'Sometimes', 'Never'],
        'correctAnswer': 0,
      },
    ],
    'java_17': [
      {
        'id': 'd_java_1',
        'question': 'What is the default value of boolean in Java?',
        'options': ['true', 'false', 'null', '0'],
        'correctAnswer': 1,
      },
      {
        'id': 'd_java_2',
        'question':
            'Which package is imported by default in every Java program?',
        'options': ['java.util', 'java.io', 'java.lang', 'java.net'],
        'correctAnswer': 2,
      },
    ],
  };

  // Mock Topics for Courses
  final _topics = {
    'python_3': [
      {
        'id': 'c1_m1',
        'name': 'Module 1: Introduction to Python',
        'description': 'Setting up and first steps.',
        'sub_topics': [
          {
            'id': 't1',
            'title': 'Installation & Environment',
            'type': 'video',
            'is_locked': false,
            'is_completed': true,
          },
          {
            'id': 't2',
            'title': 'Your First Python Script',
            'type': 'text',
            'is_locked': false,
            'is_completed': true,
            'content':
                'To run your first Python script, use the print function. This function outputs text to the console. Try running the code below:',
            'code': 'print("Hello, World!")',
            'language': 'python',
          },
        ],
      },
      {
        'id': 'c1_m2',
        'name': 'Module 2: Variables & Data Types',
        'description': 'Basic building blocks.',
        'sub_topics': [
          {
            'id': 't3',
            'title': 'Integers, Floats & Booleans',
            'type': 'text',
            'is_locked': false,
            'is_completed': true,
          },
          {
            'id': 't4',
            'title': 'String Manipulation',
            'type': 'video',
            'is_locked': false,
            'is_completed': false,
          },
        ],
      },
    ],
    'javascript_es6': [
      {
        'id': 'c2_m1',
        'name': 'Module 1: ES6 Basics',
        'description': 'Modern JS fundamentals.',
        'sub_topics': [
          {
            'id': 'js_t1',
            'title': 'Arrow Functions',
            'type': 'video',
            'is_locked': false,
            'is_completed': true,
          },
        ],
      },
    ],
    'cpp_20': [
      {
        'id': 'c3_m1',
        'name': 'Module 1: C++ Introduction',
        'description': 'Basics of C++.',
        'sub_topics': [
          {
            'id': 'cpp_t1',
            'title': 'Pointers & References',
            'type': 'text',
            'is_locked': false,
            'is_completed': false,
          },
        ],
      },
    ],
    'java_17': [
      {
        'id': 'c4_m1',
        'name': 'Module 1: Java Basics',
        'description': 'Introduction to OOP in Java.',
        'sub_topics': [
          {
            'id': 'java_t1',
            'title': 'Classes & Objects',
            'type': 'video',
            'is_locked': false,
            'is_completed': false,
          },
        ],
      },
    ],
  };

  // Mock Reviews
  final Map<String, List<Map<String, dynamic>>> _reviews = {
    'python_3': [
      {
        'id': 'r1',
        'user_name': 'Alex Johnson',
        'user_avatar': '',
        'rating': 5.0,
        'comment':
            'Best Python course for beginners! The pandas section was extremely helpful.',
        'date': '2023-10-15T12:00:00Z',
      },
    ],
    'javascript_es6': [
      {
        'id': 'r2',
        'user_name': 'Sarah Smith',
        'user_avatar': '',
        'rating': 4.5,
        'comment': 'Modern JS is easy with this course.',
        'date': '2023-11-02T15:30:00Z',
      },
    ],
  };

  // Methods to retrieve data
  Map<String, dynamic> getUserStats() => _user['stats'] as Map<String, dynamic>;

  List<Map<String, dynamic>> getAllCourses() {
    return courses.map((c) {
      final reviews = _reviews[c['id']] ?? [];
      return {...c, 'reviews': reviews};
    }).toList();
  }

  List<Map<String, dynamic>> getEnrolledCourses() {
    return courses
        .where((c) => c['is_enrolled'] == true && c['is_completed'] == false)
        .map((c) => {...c, 'reviews': _reviews[c['id']] ?? []})
        .toList();
  }

  List<Map<String, dynamic>> getCompletedCourses() {
    return courses
        .where((c) => c['is_completed'] == true)
        .map((c) => {...c, 'reviews': _reviews[c['id']] ?? []})
        .toList();
  }

  List<Map<String, dynamic>> getRecommendedCourses() {
    return courses
        .where((c) => c['is_enrolled'] == false)
        .map((c) => {...c, 'reviews': _reviews[c['id']] ?? []})
        .toList();
  }

  List<Map<String, dynamic>> getTopics(String courseId) =>
      _topics[courseId] ?? [];

  Map<String, dynamic>? getQuizForCourse(String courseId) {
    if (_courseQuizzes.containsKey(courseId)) {
      return {'course_id': courseId, 'questions': _courseQuizzes[courseId]};
    }
    return {
      'course_id': courseId,
      'questions': _courseQuizzes['python_3'], // Fallback for prototype
    };
  }

  Map<String, dynamic>? getDiagnosticQuizForCourse(String courseId) {
    if (_diagnosticQuizzes.containsKey(courseId)) {
      return {
        'course_id': courseId,
        'questions': _diagnosticQuizzes[courseId],
        'type': 'diagnostic',
      };
    }
    return {
      'course_id': courseId,
      'questions': _diagnosticQuizzes['python_3'], // Fallback for prototype
      'type': 'diagnostic',
    };
  }

  void enrollInCourse(String courseId) {
    final index = courses.indexWhere((c) => c['id'] == courseId);
    if (index != -1) {
      courses[index]['is_enrolled'] = true;
      _saveCourses();
      courses.refresh();
    }
  }

  void updateProfile(String name) {
    _user['name'] = name;
    _saveUser();
    _user.refresh();
  }

  void updateBio(String bio) {
    _user['bio'] = bio;
    _saveUser();
    _user.refresh();
  }

  void addReview(String courseId, Map<String, dynamic> review) {
    if (!_reviews.containsKey(courseId)) {
      _reviews[courseId] = [];
    }
    _reviews[courseId]!.add(review);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return _user;
  }

  Future<Map<String, dynamic>> socialLogin(String provider) async {
    await Future.delayed(const Duration(seconds: 1));
    return _user;
  }

  Future<bool> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    return true; // Always succeeds for mock
  }

  Future<bool> resetPassword(String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return true; // Always succeeds for mock
  }

  Future<Map<String, dynamic>> submitQuiz(
    String courseId,
    int correctCount,
    int totalCount,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final accuracy = correctCount / totalCount;

    // XP calculation
    final baseXP = correctCount * 10;
    final bonusXP = (accuracy * 50).toInt();
    final totalRewardXP = baseXP + bonusXP;

    // Update global user stats
    final stats = Map<String, dynamic>.from(_user['stats']);
    stats['total_xp'] = (stats['total_xp'] as int) + totalRewardXP;
    _user['stats'] = stats;
    _saveUser();
    _user.refresh();

    // AI Recommendation Logic
    String recommendationText;
    String nextAction;

    if (accuracy >= 0.8) {
      recommendationText =
          "Mastery detected! Your understanding of this module is exceptional.";
      nextAction = "Move to the next Advanced Module.";
    } else if (accuracy >= 0.5) {
      recommendationText =
          "Solid progress. You have a foundational grasp, but some nuances need review.";
      nextAction = "Check the 'Deep Dive' resources for this module.";
    } else {
      recommendationText =
          "Learning gap identified. We recommend revisiting the core concepts of this module.";
      nextAction = "Review Topic: Core Syntax & Structures.";
    }

    final result = {
      'course_id': courseId,
      'score': (accuracy * 100).toInt(),
      'xp_earned': totalRewardXP,
      'accuracy': accuracy,
      'ml_analysis': {
        'confidence_score': 0.92,
        'recommendation': recommendationText,
        'next_action': nextAction,
        'strength': accuracy > 0.7 ? 'Logical Reasoning' : 'Basic Syntax',
      },
    };

    lastEvaluation.value = result;
    _saveEval();

    return result;
  }

  // --- Analytics & Practice Enhanced Data ---

  List<Map<String, dynamic>> getTopicMastery(String languageId) {
    // Standardizing on 8 Universal Concepts
    return [
      {
        'id': 'UNIV_VAR',
        'name': 'Variables & Data Types',
        'mastery': 0.82,
        'last_practiced': DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
      },
      {
        'id': 'UNIV_COND',
        'name': 'Conditionals',
        'mastery': 0.68,
        'last_practiced': DateTime.now()
            .subtract(const Duration(days: 3))
            .toIso8601String(),
      },
      {
        'id': 'UNIV_LOOP',
        'name': 'Loops',
        'mastery': 0.45,
        'last_practiced': DateTime.now()
            .subtract(const Duration(days: 9))
            .toIso8601String(),
      },
      {
        'id': 'UNIV_FUNC',
        'name': 'Functions',
        'mastery': 0.0,
        'last_practiced': DateTime.now().toIso8601String(),
      },
      {
        'id': 'UNIV_COLL',
        'name': 'Collections',
        'mastery': 0.0,
        'last_practiced': DateTime.now().toIso8601String(),
      },
      {
        'id': 'UNIV_ERR',
        'name': 'Error Handling',
        'mastery': 0.0,
        'last_practiced': DateTime.now().toIso8601String(),
      },
      {
        'id': 'UNIV_OOP_BASIC',
        'name': 'OOP Basics',
        'mastery': 0.0,
        'last_practiced': DateTime.now().toIso8601String(),
      },
      {
        'id': 'UNIV_OOP_ADV',
        'name': 'Advanced OOP',
        'mastery': 0.0,
        'last_practiced': DateTime.now().toIso8601String(),
      },
    ];
  }

  List<Map<String, dynamic>> getRecentSessions(String languageId) {
    return [
      {
        'id': 's1',
        'timestamp': DateTime.now()
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
        'concept_id': 'UNIV_VAR',
        'concept_name': 'Variables & Data Types',
        'sub_topic': 'variable_scope',
        'score': 0.85,
        'difficulty': 0.65,
        'mastery_gain': 0.08,
        'questions_answered': 10,
      },
      {
        'id': 's2',
        'timestamp': DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
        'concept_id': 'UNIV_COND',
        'concept_name': 'Conditionals',
        'sub_topic': 'if_else_basics',
        'score': 0.70,
        'difficulty': 0.50,
        'mastery_gain': 0.05,
        'questions_answered': 8,
      },
      {
        'id': 's3',
        'timestamp': DateTime.now()
            .subtract(const Duration(days: 8))
            .toIso8601String(),
        'concept_id': 'UNIV_LOOP',
        'concept_name': 'Loops',
        'sub_topic': 'for_loop_basics',
        'score': 0.60,
        'difficulty': 0.45,
        'mastery_gain': -0.03, // Show decay simulation
        'questions_answered': 12,
      },
    ];
  }

  Map<String, dynamic> getAIRecommendation(String languageId) {
    final masteryData = getTopicMastery(languageId);

    // 1. Check for Decay (Urgent Review)
    for (var m in masteryData) {
      final originalMastery = (m['mastery'] as num).toDouble();
      if (originalMastery == 0) continue;

      final lastPracticed = DateTime.parse(m['last_practiced']);
      final daysPassed = DateTime.now().difference(lastPracticed).inDays;
      // mastery * e^(-0.02 * daysPassed)
      final decayedMastery = originalMastery * exp(-0.02 * daysPassed);

      if (decayedMastery < 0.5) {
        return {
          'concept_id': m['id'],
          'concept_name': m['name'],
          'sub_topic': 'Reinforcement Session',
          'target_difficulty': originalMastery,
          'estimated_time_minutes': 15,
          'reason':
              'Your mastery in ${m['name']} has decayed to ${(decayedMastery * 100).round()}% and needs reinforcement.',
          'prerequisite_met': true,
        };
      }
    }

    // 2. Check for Next Logical Topic (New Learning)
    for (var m in masteryData) {
      if ((m['mastery'] as num).toDouble() == 0) {
        return {
          'concept_id': m['id'],
          'concept_name': m['name'],
          'sub_topic': 'Introduction',
          'target_difficulty': 0.3,
          'estimated_time_minutes': 20,
          'reason':
              'You are ready to advance! ${m['name']} is the next logical step in your learning path.',
          'prerequisite_met': true,
        };
      }
    }

    // Default Fallback
    return {
      'concept_id': 'UNIV_VAR',
      'concept_name': 'Variables & Data Types',
      'sub_topic': 'Advanced Scoping',
      'target_difficulty': 0.7,
      'estimated_time_minutes': 10,
      'reason':
          'Keep your skills sharp with a quick advanced session on Variables.',
      'prerequisite_met': true,
    };
  }
}

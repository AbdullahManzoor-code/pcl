import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

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

  // Mock User Data
  final RxMap<String, dynamic> _user = <String, dynamic>{
    'name': 'Mian',
    'email': 'mian@example.com',
    'profile_pic': null,
    'bio':
        'Passionate coder and Flutter enthusiast. Learning something new every day!',
    'stats': {
      'consecutive_days': 15,
      'total_hours': 30,
      'completed_courses': 8,
      'total_xp': 12500,
      'badges': ['Fast Learner', 'Problem Solver', 'Python Pro'],
      'today_points': 8,
      'today_minutes': 12,
    },
  }.obs;

  // Mock Courses Data - Made public and reactive for global sync
  final RxList<Map<String, dynamic>> courses = <Map<String, dynamic>>[
    {
      'id': 'c1',
      'title': 'Python for Data Science',
      'category': 'Data Science',
      'level': 'Beginner',
      'image': 'assets/images/course1.png',
      'progress': 0.3,
      'is_completed': false,
      'is_enrolled': true,
      'rating': 4.8,
      'review_count': 1250,
      'description':
          'Master Python from scratch! This comprehensive course takes you from the very basics of programming to advanced data manipulation. You will learn about data structures, control flow, functions, and object-oriented programming. Furthermore, you\'ll dive deep into data science libraries like Pandas, NumPy, and Matplotlib to analyze and visualize real-world datasets. By the end of this course, you will be able to build your own data models and solve complex algorithmic problems using Python.',
    },
    {
      'id': 'c2',
      'title': 'Flutter & Dart',
      'category': 'Mobile Development',
      'level': 'Intermediate',
      'image': 'assets/images/course2.png',
      'progress': 1.0,
      'is_completed': true,
      'is_enrolled': true,
      'rating': 4.9,
      'review_count': 2100,
      'description':
          'Build beautiful native apps for iOS and Android with a single codebase. This course is designed to turn you into a professional Flutter developer. We start with the Dart programming language basics and move quickly into Flutter UI development. You will learn about Stateless and Stateful widgets, state management using Provider and GetX, REST API integration, local databases, and Firebase. We also cover animations, custom painters, and app performance optimization to ensure your apps are world-class.',
    },
    {
      'id': 'c3',
      'title': 'Advanced Algorithms',
      'category': 'Computer Science',
      'level': 'Advanced',
      'image': 'assets/images/course3.png',
      'progress': 0.0,
      'is_completed': false,
      'is_enrolled': false,
      'rating': 4.7,
      'review_count': 850,
      'description':
          'Deep dive into sorting, searching, and graph algorithms. Optimize your code for performance and ace technical interviews at top tech companies. This course covers dynamic programming, backtracking, greedy algorithms, and complex data structures like AVL trees and Graphs.',
    },
    {
      'id': 'c4',
      'title': 'Web Development Bootcamp',
      'category': 'Web Development',
      'level': 'Beginner',
      'image': 'assets/images/course4.png',
      'progress': 0.6,
      'is_completed': false,
      'is_enrolled': true,
      'rating': 4.8,
      'review_count': 3500,
      'description':
          'The only course you need to learn to code and become a full-stack web developer. HTML, CSS, Javascript, Node, and more! Go from zero to hero with hands-on projects including a blog, a social network, and an e-commerce platform.',
    },
    {
      'id': 'c5',
      'title': 'UI/UX Design Masterclass',
      'category': 'Design',
      'level': 'Intermediate',
      'image': 'assets/images/course5.png',
      'progress': 1.0,
      'is_completed': true,
      'is_enrolled': true,
      'rating': 4.6,
      'review_count': 1200,
      'description':
          'Learn to design websites and mobile apps that are beautiful and easy to use. Master Figma, Adobe XD, and design principles. Understand user psychology, color theory, and prototyping.',
    },
    {
      'id': 'c6',
      'title': 'Machine Learning A-Z',
      'category': 'Data Science',
      'level': 'Advanced',
      'image': 'assets/images/course6.png',
      'progress': 0.0,
      'is_completed': false,
      'is_enrolled': false,
      'rating': 4.7,
      'review_count': 1800,
      'description':
          'Learn to create Machine Learning Algorithms in Python and R from two Data Science experts. Code templates included. Covers regression, classification, clustering, association rule learning, and reinforcement learning.',
    },
    {
      'id': 'c7',
      'title': 'Cybersecurity Basics',
      'category': 'Security',
      'level': 'Beginner',
      'image': 'assets/images/course7.png',
      'progress': 0.1,
      'is_completed': false,
      'is_enrolled': true,
      'rating': 4.5,
      'review_count': 900,
      'description':
          'Understand the fundamental concepts of cybersecurity and how to protect yourself and your systems from cyber attacks. Learn about network security, cryptography, and ethical hacking basics.',
    },
    {
      'id': 'c8',
      'title': 'React.js Complete Guide',
      'category': 'Web Development',
      'level': 'Intermediate',
      'image': 'assets/images/course8.png',
      'progress': 0.0,
      'is_completed': false,
      'is_enrolled': false,
      'rating': 4.8,
      'review_count': 2800,
      'description':
          'Dive deep into React.js. Learn hooks, Redux, and building scalable web applications with the most popular JS library. Create dynamic interfaces and single-page applications.',
    },
    {
      'id': 'c9',
      'title': 'DevOps Fundamentals',
      'category': 'DevOps',
      'level': 'Beginner',
      'image': 'assets/images/course9.png',
      'progress': 0.0,
      'is_completed': false,
      'is_enrolled': false,
      'rating': 4.6,
      'review_count': 600,
      'description':
          'Learn the basics of CI/CD, Docker, and Kubernetes. Bridge the gap between development and operations. Understand how to automate the software delivery process.',
    },
    {
      'id': 'c10',
      'title': 'Game Dev with Unity',
      'category': 'Game Development',
      'level': 'Intermediate',
      'image': 'assets/images/course10.png',
      'progress': 0.0,
      'is_completed': false,
      'is_enrolled': false,
      'rating': 4.7,
      'review_count': 1100,
      'description':
          'Start your game development journey! Build 2D and 3D games using Unity and C# from scratch. Understand physics engines, animations, and game mechanics.',
    },
  ].obs;

  // Mock Quizzes for each course (5 MCQs each)
  final Map<String, List<Map<String, dynamic>>> _courseQuizzes = {
    'c1': [
      {
        'id': 'q1_1',
        'text': 'What is the correct way to create a list in Python?',
        'options': ['list = []', 'list = {}', 'list = ()', 'list = <>'],
        'correct_answer_index': 0,
      },
      {
        'id': 'q1_2',
        'text': 'Which keyword is used to define a function in Python?',
        'options': ['func', 'define', 'def', 'function'],
        'correct_answer_index': 2,
      },
      {
        'id': 'q1_3',
        'text': 'How do you insert a comment in Python code?',
        'options': ['//', '/*', '#', '--'],
        'correct_answer_index': 2,
      },
      {
        'id': 'q1_4',
        'text':
            'Which data type is used to store multiple items in a single variable where order is preserved and change is allowed?',
        'options': ['Set', 'Tuple', 'Dictionary', 'List'],
        'correct_answer_index': 3,
      },
      {
        'id': 'q1_5',
        'text': 'What is the output of print(2 ** 3)?',
        'options': ['5', '6', '8', '9'],
        'correct_answer_index': 2,
      },
    ],
    'c2': [
      {
        'id': 'q2_1',
        'text': 'Which widget is the root of most Flutter apps?',
        'options': ['Scaffold', 'MaterialApp', 'Container', 'SizedBox'],
        'correct_answer_index': 1,
      },
      {
        'id': 'q2_2',
        'text': 'What language is Flutter written in?',
        'options': ['Java', 'Kotlin', 'Swift', 'Dart'],
        'correct_answer_index': 3,
      },
      {
        'id': 'q2_3',
        'text': 'Which command is used to fetch dependencies in Flutter?',
        'options': [
          'flutter get',
          'flutter pub get',
          'flutter build',
          'flutter doctor',
        ],
        'correct_answer_index': 1,
      },
      {
        'id': 'q2_4',
        'text':
            'What is the difference between Stateless and Stateful widgets?',
        'options': [
          'Stateless can change its appearance over time.',
          'Stateful is always static.',
          'Stateful can change its appearance in response to events.',
          'There is no difference.',
        ],
        'correct_answer_index': 2,
      },
      {
        'id': 'q2_5',
        'text': 'Where do you define the dependencies for a Flutter project?',
        'options': [
          'main.dart',
          'pubspec.yaml',
          'index.html',
          'AndroidManifest.xml',
        ],
        'correct_answer_index': 1,
      },
    ],
    'c3': [
      {
        'id': 'q3_1',
        'text': 'What is the average time complexity of Quicksort?',
        'options': ['O(n)', 'O(n log n)', 'O(n^2)', 'O(log n)'],
        'correct_answer_index': 1,
      },
      {
        'id': 'q3_2',
        'text': 'Which data structure follows LIFO (Last In First Out)?',
        'options': ['Queue', 'Linked List', 'Stack', 'Tree'],
        'correct_answer_index': 2,
      },
      {
        'id': 'q3_3',
        'text': 'What is a bipartite graph?',
        'options': [
          'A graph with two cycles.',
          'A graph whose vertices can be divided into two independent sets.',
          'A graph where every vertex has degree two.',
          'A graph with no edges.',
        ],
        'correct_answer_index': 1,
      },
      {
        'id': 'q3_4',
        'text': 'What is Dynamic Programming mainly used for?',
        'options': [
          'Linear search',
          'Sorting large datasets',
          'Solving problems with overlapping subproblems',
          'Rendering graphics',
        ],
        'correct_answer_index': 2,
      },
      {
        'id': 'q3_5',
        'text':
            'Which algorithm is used to find the shortest path in a weighted graph?',
        'options': ['BFS', 'DFS', 'Dijkstra\'s', 'Binary Search'],
        'correct_answer_index': 2,
      },
    ],
    'c4': [
      {
        'id': 'q4_1',
        'text': 'What does HTML stand for?',
        'options': [
          'Hyper Text Markup Language',
          'High Text Machine Language',
          'Hyper Tabular Markup Language',
          'None of the above',
        ],
        'correct_answer_index': 0,
      },
      {
        'id': 'q4_2',
        'text': 'Which tag is used to link an external CSS file?',
        'options': ['<style>', '<link>', '<script>', '<href>'],
        'correct_answer_index': 1,
      },
      {
        'id': 'q4_3',
        'text': 'What is the purpose of "use strict" in JavaScript?',
        'options': [
          'To enable older browser features.',
          'To enforce stricter parsing and error handling.',
          'To make the code run faster.',
          'To include external libraries.',
        ],
        'correct_answer_index': 1,
      },
      {
        'id': 'q4_4',
        'text':
            'Which HTTP method is used to send data to a server to create/update a resource?',
        'options': ['GET', 'POST', 'DELETE', 'HEAD'],
        'correct_answer_index': 1,
      },
      {
        'id': 'q4_5',
        'text': 'What is the DOM in web development?',
        'options': [
          'Data Object Model',
          'Document Object Model',
          'Digital Output Management',
          'None of the above',
        ],
        'correct_answer_index': 1,
      },
    ],
    'c5': [
      {
        'id': 'q5_1',
        'text': 'What is the "Golden Ratio" in design?',
        'options': ['1:1', '1:2', '1:1.618', '1:3'],
        'correct_answer_index': 2,
      },
      {
        'id': 'q5_2',
        'text': 'Which color model is primarily used for digital screens?',
        'options': ['CMYK', 'RYB', 'RGB', 'Pantone'],
        'correct_answer_index': 2,
      },
      {
        'id': 'q5_3',
        'text': 'What does UX stand for?',
        'options': [
          'User Extension',
          'User Experience',
          'Unique Excellence',
          'Universal X-factor',
        ],
        'correct_answer_index': 1,
      },
      {
        'id': 'q5_4',
        'text': 'What is a "Wireframe"?',
        'options': [
          'A colorful final design.',
          'A low-fidelity structural blueprint.',
          'An animation tool.',
          'A CSS framework.',
        ],
        'correct_answer_index': 1,
      },
      {
        'id': 'q5_5',
        'text': 'What is hierarchy in UI design?',
        'options': [
          'The order of files.',
          'The arrangement of elements to signal importance.',
          'The font size only.',
          'The spacing between pages.',
        ],
        'correct_answer_index': 1,
      },
    ],
    'c6': [
      {
        'id': 'q6_1',
        'text': 'What is supervised learning?',
        'options': [
          'Learning without labels.',
          'Learning from labeled training data.',
          'Learning by playing a game.',
          'None of the above',
        ],
        'correct_answer_index': 1,
      },
      {
        'id': 'q6_2',
        'text': 'What is a common metric for regression problems?',
        'options': ['Accuracy', 'F1 Score', 'Mean Squared Error', 'Recall'],
        'correct_answer_index': 2,
      },
      {
        'id': 'q6_3',
        'text': 'What is overfitting?',
        'options': [
          'When the model performs well on training data but poorly on unseen data.',
          'When the model is too simple.',
          'When the data is too small.',
          'When the model runs too fast.',
        ],
        'correct_answer_index': 0,
      },
      {
        'id': 'q6_4',
        'text':
            'Which of these is a popular library for Machine Learning in Python?',
        'options': ['Scikit-learn', 'Request', 'Django', 'Flask'],
        'correct_answer_index': 0,
      },
      {
        'id': 'q6_5',
        'text': 'What is the purpose of a validation set?',
        'options': [
          'To train the model.',
          'To evaluate the model before the final test.',
          'To clean the data.',
          'To deploy the model.',
        ],
        'correct_answer_index': 1,
      },
    ],
    'c7': [
      {
        'id': 'q7_1',
        'text': 'What is phishing?',
        'options': [
          'A way to catch fish.',
          'A social engineering attack to steal data.',
          'A type of encryption.',
          'A debugging tool.',
        ],
        'correct_answer_index': 1,
      },
      {
        'id': 'q7_2',
        'text': 'What does VPN stand for?',
        'options': [
          'Virtual Private Network',
          'Verification Private Number',
          'Virtual Public Network',
          'None of the above',
        ],
        'correct_answer_index': 0,
      },
      {
        'id': 'q7_3',
        'text': 'What is the primary goal of a firewall?',
        'options': [
          'To cool down the hardware.',
          'To block unauthorized access to a network.',
          'To increase internet speed.',
          'To backup files.',
        ],
        'correct_answer_index': 1,
      },
      {
        'id': 'q7_4',
        'text': 'What is symmetric encryption?',
        'options': [
          'Encryption that uses two keys.',
          'Encryption that uses the same key for both encryption and decryption.',
          'Encryption that cannot be reversed.',
          'None of the above.',
        ],
        'correct_answer_index': 1,
      },
      {
        'id': 'q7_5',
        'text': 'What is malware?',
        'options': [
          'Software that works properly.',
          'Software designed to cause damage or gain unauthorized access.',
          'A type of hardware.',
          'A security protocol.',
        ],
        'correct_answer_index': 1,
      },
    ],
    'c8': [
      {
        'id': 'q8_1',
        'text': 'What is a "component" in React?',
        'options': [
          'A part of the computer.',
          'A reusable piece of the UI.',
          'A CSS file.',
          'A server-side script.',
        ],
        'correct_answer_index': 1,
      },
      {
        'id': 'q8_2',
        'text':
            'Which hook is used to manage state in a React functional component?',
        'options': ['useEffect', 'useMemo', 'useState', 'useContext'],
        'correct_answer_index': 2,
      },
      {
        'id': 'q8_3',
        'text': 'What is JSX?',
        'options': [
          'A new database.',
          'A JavaScript extension that allows writing HTML-like code.',
          'A CSS preprocessor.',
          'A routing library.',
        ],
        'correct_answer_index': 1,
      },
      {
        'id': 'q8_4',
        'text': 'How do you pass data between React components?',
        'options': [
          'Using variables',
          'Using Props',
          'Using Cookies',
          'Using URL parameters',
        ],
        'correct_answer_index': 1,
      },
      {
        'id': 'q8_5',
        'text': 'What is the Virtual DOM?',
        'options': [
          'A faster version of the actual DOM.',
          'A copy of the DOM kept in memory.',
          'A hardware component.',
          'None of the above.',
        ],
        'correct_answer_index': 1,
      },
    ],
    'c9': [
      {
        'id': 'q9_1',
        'text': 'What does CI/CD stand for?',
        'options': [
          'Coding Integration / Coding Deployment',
          'Continuous Integration / Continuous Deployment',
          'Core Integration / Core Delivery',
          'Common Integration / Common Delivery',
        ],
        'correct_answer_index': 1,
      },
      {
        'id': 'q9_2',
        'text': 'What is Docker used for?',
        'options': [
          'To manage databases.',
          'To containerize applications.',
          'To write code.',
          'To host websites.',
        ],
        'correct_answer_index': 1,
      },
      {
        'id': 'q9_3',
        'text': 'What is Kubernetes primarily used for?',
        'options': [
          'To create graphics.',
          'To orchestrate containers.',
          'To manage version control.',
          'To design APIs.',
        ],
        'correct_answer_index': 1,
      },
      {
        'id': 'q9_4',
        'text': 'What is "Infrastructure as Code"?',
        'options': [
          'Writing code for a building.',
          'Managing infrastructure through machine-readable definition files.',
          'Installing OS manually.',
          'None of the above.',
        ],
        'correct_answer_index': 1,
      },
      {
        'id': 'q9_5',
        'text':
            'Which tool is commonly used for automation and configuration management?',
        'options': ['Ansible', 'Photoshop', 'Excel', 'Chrome'],
        'correct_answer_index': 0,
      },
    ],
    'c10': [
      {
        'id': 'q10_1',
        'text': 'Which engine is Unity primarily built on?',
        'options': ['Unreal', 'CryEngine', 'Unity Engine', 'Source'],
        'correct_answer_index': 2,
      },
      {
        'id': 'q10_2',
        'text': 'What programming language is most commonly used in Unity?',
        'options': ['C++', 'Python', 'C#', 'Java'],
        'correct_answer_index': 2,
      },
      {
        'id': 'q10_3',
        'text': 'What is a "Prefab" in Unity?',
        'options': [
          'A pre-fabricated building.',
          'A template for a GameObject.',
          'A light source.',
          'A type of texture.',
        ],
        'correct_answer_index': 1,
      },
      {
        'id': 'q10_4',
        'text': 'What is the purpose of the "Update()" method in Unity?',
        'options': [
          'To run code once at the start.',
          'To run code every frame.',
          'To clean memory.',
          'To close the game.',
        ],
        'correct_answer_index': 1,
      },
      {
        'id': 'q10_5',
        'text':
            'Which component is needed to make a GameObject affected by physics?',
        'options': ['MeshFilter', 'BoxCollider', 'Rigidbody', 'AudioSource'],
        'correct_answer_index': 2,
      },
    ],
  };

  final Map<String, List<Map<String, dynamic>>> _diagnosticQuizzes = {
    'c1': [
      {
        'id': 'd1',
        'text': 'Have you ever programmed in Python before?',
        'options': [
          'No',
          'Yes, a little',
          'Yes, I am comfortable',
          'I am an expert',
        ],
        'correct_answer_index': 1,
      },
      {
        'id': 'd2',
        'text': 'What is the result of 2 + 2 in Python?',
        'options': ['3', '4', '5', 'None'],
        'correct_answer_index': 1,
      },
    ],
    'c2': [
      {
        'id': 'd3',
        'text': 'What is Flutter?',
        'options': ['A language', 'A UI framework', 'A database', 'An IDE'],
        'correct_answer_index': 1,
      },
      {
        'id': 'd4',
        'text': 'Which language does Flutter use?',
        'options': ['Java', 'Swift', 'Dart', 'Kotlin'],
        'correct_answer_index': 2,
      },
    ],
    'c3': [
      {
        'id': 'd5',
        'text': 'What is the Big O complexity of binary search?',
        'options': ['O(n)', 'O(log n)', 'O(n^2)', 'O(1)'],
        'correct_answer_index': 1,
      },
    ],
  };

  // Mock Topics for Courses
  final _topics = {
    'c1': [
      {
        'id': 'c1_m1',
        'title': 'Module 1: Introduction to Python',
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
        'title': 'Module 2: Variables & Data Types',
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
      {
        'id': 'c1_m3',
        'title': 'Module 3: List & Dictionaries',
        'description': 'Storing collections of data.',
        'sub_topics': [
          {
            'id': 't5',
            'title': 'Working with Lists',
            'type': 'video',
            'is_locked': false,
            'is_completed': false,
          },
          {
            'id': 't6',
            'title': 'Dictionary Operations',
            'type': 'quiz',
            'is_locked': false,
            'is_completed': false,
          },
        ],
      },
      {
        'id': 'c1_m4',
        'title': 'Module 4: Control flow - Part 1',
        'description': 'Making decisions.',
        'sub_topics': [
          {
            'id': 't7',
            'title': 'If-Else Statements',
            'type': 'text',
            'is_locked': true,
            'is_completed': false,
          },
        ],
      },
      {
        'id': 'c1_m5',
        'title': 'Module 5: Control flow - Part 2',
        'description': 'Looping through data.',
        'sub_topics': [
          {
            'id': 't8',
            'title': 'For Loops & While Loops',
            'type': 'video',
            'is_locked': true,
            'is_completed': false,
          },
        ],
      },
      {
        'id': 'c1_m6',
        'title': 'Module 6: Functions & Modules',
        'description': 'Writing reusable code.',
        'sub_topics': [
          {
            'id': 't9',
            'title': 'Defining Functions',
            'type': 'text',
            'is_locked': true,
            'is_completed': false,
          },
          {
            'id': 't10',
            'title': 'Importing Modules',
            'type': 'video',
            'is_locked': true,
            'is_completed': false,
          },
        ],
      },
      {
        'id': 'c1_m7',
        'title': 'Module 7: File I/O',
        'description': 'Reading and writing files.',
        'sub_topics': [
          {
            'id': 't11',
            'title': 'Working with Text Files',
            'type': 'text',
            'is_locked': true,
            'is_completed': false,
          },
          {
            'id': 't12',
            'title': 'JSON Data Processing',
            'type': 'quiz',
            'is_locked': true,
            'is_completed': false,
          },
        ],
      },
      {
        'id': 'c1_m8',
        'title': 'Module 8: NumPy & Math',
        'description': 'Numerical Python basics.',
        'sub_topics': [
          {
            'id': 't13',
            'title': 'NDArrays',
            'type': 'video',
            'is_locked': true,
            'is_completed': false,
          },
        ],
      },
      {
        'id': 'c1_m9',
        'title': 'Module 9: Pandas Dataframes',
        'description': 'Tabular data analysis.',
        'sub_topics': [
          {
            'id': 't14',
            'title': 'Selecting & Filtering',
            'type': 'text',
            'is_locked': true,
            'is_completed': false,
          },
        ],
      },
      {
        'id': 'c1_m10',
        'title': 'Module 10: Data Visualization',
        'description': 'Matplotlib and Seaborn.',
        'sub_topics': [
          {
            'id': 't15',
            'title': 'Plotting Basics',
            'type': 'video',
            'is_locked': true,
            'is_completed': false,
          },
          {
            'id': 't16',
            'title': 'Final Python Quiz',
            'type': 'quiz',
            'is_locked': true,
            'is_completed': false,
          },
        ],
      },
    ],
    'c2': [
      {
        'id': 'c2_m1',
        'title': 'Module 1: Flutter Setup',
        'description': 'Getting ready for development.',
        'sub_topics': [
          {
            'id': 't21',
            'title': 'SDK Installation',
            'type': 'video',
            'is_locked': false,
            'is_completed': true,
          },
        ],
      },
      {
        'id': 'c2_m2',
        'title': 'Module 2: Dart Programming',
        'description': 'Language fundamentals.',
        'sub_topics': [
          {
            'id': 't22',
            'title': 'Sound Null Safety',
            'type': 'text',
            'is_locked': false,
            'is_completed': true,
          },
          {
            'id': 't23',
            'title': 'Async/Await',
            'type': 'video',
            'is_locked': false,
            'is_completed': true,
          },
        ],
      },
      {
        'id': 'c2_m3',
        'title': 'Module 3: Widgets Basics',
        'description': 'Stateless vs Stateful.',
        'sub_topics': [
          {
            'id': 't24',
            'title': 'Common Widgets',
            'type': 'video',
            'is_locked': false,
            'is_completed': true,
          },
        ],
      },
      {
        'id': 'c2_m4',
        'title': 'Module 4: Layouts',
        'description': 'Row, Column & Stack.',
        'sub_topics': [
          {
            'id': 't25',
            'title': 'Flexbox in Flutter',
            'type': 'text',
            'is_locked': false,
            'is_completed': true,
          },
        ],
      },
      {
        'id': 'c2_m5',
        'title': 'Module 5: State Management',
        'description': 'Provider and GetX.',
        'sub_topics': [
          {
            'id': 't26',
            'title': 'Reactive Variables',
            'type': 'video',
            'is_locked': false,
            'is_completed': true,
          },
        ],
      },
      {
        'id': 'c2_m6',
        'title': 'Module 6: Navigation',
        'description': 'Routing techniques.',
        'sub_topics': [
          {
            'id': 't27',
            'title': 'Named Routes',
            'type': 'text',
            'is_locked': false,
            'is_completed': true,
          },
        ],
      },
      {
        'id': 'c2_m7',
        'title': 'Module 7: API Integration',
        'description': 'Fetching remote data.',
        'sub_topics': [
          {
            'id': 't28',
            'title': 'HTTP Package',
            'type': 'video',
            'is_locked': false,
            'is_completed': true,
          },
        ],
      },
      {
        'id': 'c2_m8',
        'title': 'Module 8: Forms & Inputs',
        'description': 'Handling user data.',
        'sub_topics': [
          {
            'id': 't29',
            'title': 'TextFormFields',
            'type': 'quiz',
            'is_locked': false,
            'is_completed': true,
          },
        ],
      },
      {
        'id': 'c2_m9',
        'title': 'Module 9: Animations',
        'description': 'Implicit & Explicit.',
        'sub_topics': [
          {
            'id': 't30',
            'title': 'AnimatedContainer',
            'type': 'video',
            'is_locked': false,
            'is_completed': true,
          },
        ],
      },
      {
        'id': 'c2_m10',
        'title': 'Module 10: Deployment',
        'description': 'Publishing to Stores.',
        'sub_topics': [
          {
            'id': 't31',
            'title': 'App Store Release',
            'type': 'text',
            'is_locked': false,
            'is_completed': true,
          },
          {
            'id': 't32',
            'title': 'Final Flutter Project',
            'type': 'quiz',
            'is_locked': false,
            'is_completed': true,
          },
        ],
      },
    ],
  };

  // Mock Reviews
  final Map<String, List<Map<String, dynamic>>> _reviews = {
    'c1': [
      {
        'id': 'r1',
        'user_name': 'Alex Johnson',
        'user_avatar': '',
        'rating': 5.0,
        'comment':
            'Best Python course for beginners! The pandas section was extremely helpful.',
        'date': '2023-10-15T12:00:00Z',
      },
      {
        'id': 'r2',
        'user_name': 'Sarah Smith',
        'user_avatar': '',
        'rating': 4.5,
        'comment':
            'Very clear explanations, but I wish there were more exercises in Module 5.',
        'date': '2023-11-02T15:30:00Z',
      },
      {
        'id': 'r3',
        'user_name': 'Michael Chen',
        'user_avatar': '',
        'rating': 5.0,
        'comment': 'Excellent pacing and great projects.',
        'date': '2023-12-01T09:00:00Z',
      },
    ],
    'c2': [
      {
        'id': 'r4',
        'user_name': 'Emily Davis',
        'user_avatar': '',
        'rating': 5.0,
        'comment':
            'Flutter is amazing and this course makes it so easy to learn.',
        'date': '2023-09-20T10:00:00Z',
      },
      {
        'id': 'r5',
        'user_name': 'David Wilson',
        'user_avatar': '',
        'rating': 4.8,
        'comment': 'The State Management section is a lifesaver!',
        'date': '2023-10-25T14:45:00Z',
      },
    ],
    'c3': [
      {
        'id': 'r6',
        'user_name': 'James Miller',
        'user_avatar': '',
        'rating': 4.7,
        'comment':
            'Tough course but very rewarding. I actually passed my interview because of this.',
        'date': '2023-11-10T11:20:00Z',
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
    return null;
  }

  Map<String, dynamic>? getDiagnosticQuizForCourse(String courseId) {
    if (_diagnosticQuizzes.containsKey(courseId)) {
      return {
        'course_id': courseId,
        'questions': _diagnosticQuizzes[courseId],
        'type': 'diagnostic',
      };
    }
    return null;
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

  Future<Map<String, dynamic>> submitQuiz(
    String courseId,
    int correctCount,
    int totalCount,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final accuracy = correctCount / totalCount;

    // Simulated ML Reward System: XP calculation
    // Base XP: 10 per correct answer
    // Bonus XP: Max 50 based on accuracy
    // ML Confidence: Simulated factor
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
        'confidence_score': 0.92, // Simulated ML confidence
        'recommendation': recommendationText,
        'next_action': nextAction,
        'strength': accuracy > 0.7 ? 'Logical Reasoning' : 'Basic Syntax',
      },
    };

    lastEvaluation.value = result;
    _saveEval();

    return result;
  }
}

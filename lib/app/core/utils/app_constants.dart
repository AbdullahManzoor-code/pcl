/// App-wide constants for consistent configuration
class AppConstants {
  // Timing & Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration mockApiDelay = Duration(seconds: 1);
  static const Duration snackbarDuration = Duration(seconds: 3);

  // Pagination & Limits
  static const int defaultPageSize = 20;
  static const int maxSearchResults = 50;
  static const int maxRecentSessions = 10;
  static const int minPasswordLength = 6;

  // Quiz & Practice
  static const List<int> questionCountOptions = [5, 10, 15, 20, 30, 50];
  static const int defaultQuestionCount = 10;
  static const double minDifficulty = 0.3;
  static const double maxDifficulty = 1.0;

  // Mastery & Analytics
  static const double masteryDecayRate = 0.02;
  static const double masteryThreshold = 0.5;
  static const double masteryExcellentThreshold = 0.8;

  // UI Spacing
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;

  // Image & Cache
  static const Duration imageCacheDuration = Duration(days: 7);
  static const int maxCacheSize = 100; // MB

  // Notifications
  static const int practiceReminderHour = 18; // 6 PM
  static const int dailyStreakNotificationId = 1;
  static const int practiceReminderNotificationId = 2;

  // Storage Keys
  static const String themeKey = 'app_theme';
  static const String userKey = 'user_data';
  static const String coursesKey = 'courses_cache';
  static const String lastSyncKey = 'last_sync_timestamp';

  // Universal Concepts
  static const List<String> universalConcepts = [
    'Variables & Data Types',
    'Conditionals',
    'Loops',
    'Functions',
    'Collections',
    'Error Handling',
    'OOP Basics',
    'Advanced OOP',
  ];
}

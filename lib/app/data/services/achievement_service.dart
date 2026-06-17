import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pcl/app/core/utils/app_logger.dart';
import '../models/achievement_model.dart';
import 'api_config.dart';
import 'auth_service.dart';
import 'network_error_handler.dart';

class AchievementService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();
  static String get apiBaseUrl => ApiConfig.baseUrl;

  /// Fetch all achievements for the logged-in user from the backend
  Future<List<Achievement>> getAchievements() async {
    final token = _authService.getAccessToken();
    if (token == null) {
      throw NetworkException(
        type: NetworkErrorType.unauthorized,
        message: 'You are not logged in.',
      );
    }

    // Ensure auth token is valid before making the request
    await _authService.refreshToken();

    AppLogger.info(
      'AchievementService.getAchievements(): GET /api/user/achievements',
    );

    try {
      final response = await http
          .get(
            Uri.parse('$apiBaseUrl/api/user/achievements'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final achievements = data.map((json) {
          return Achievement.fromJson(
            json,
            icon: _getIconForCategory(json['category']),
            color: _getColorForCategory(json['category']),
          );
        }).toList();
        AppLogger.info(
          'AchievementService.getAchievements(): success, count=${achievements.length}',
        );
        return achievements;
      } else {
        throw NetworkException(
          type: NetworkErrorHandler.detectErrorType(null, response.statusCode),
          message: 'Failed to fetch achievements',
          statusCode: response.statusCode,
          details: response.body,
        );
      }
    } on TimeoutException {
      throw NetworkException(
        type: NetworkErrorType.timeout,
        message: 'Request to fetch achievements timed out',
      );
    } on NetworkException catch (e) {
      // Return dummy data for development/testing
      AppLogger.warning(
        'AchievementService.getAchievements(): using dummy data due to error: $e',
      );
      return _dummyAchievements();
    } catch (e, stackTrace) {
      AppLogger.error(
        'AchievementService.getAchievements(): failed',
        e,
        stackTrace,
      );
      throw NetworkErrorHandler.createException(
        e,
        'An unexpected error occurred while fetching achievements.',
      );
    }
  }

  // Dummy achievements for when the API is unavailable (development mode)
  List<Achievement> _dummyAchievements() {
    return [
      Achievement(
        id: '1',
        title: 'First Steps',
        description: 'Complete your first lesson',
        icon: Icons.star_rounded,
        color: Colors.amber,
        requiredCount: 1,
        category: 'streak',
      ),
      Achievement(
        id: '2',
        title: 'Quiz Master',
        description: 'Score 100% on a quiz',
        icon: Icons.quiz_rounded,
        color: Colors.purple,
        requiredCount: 1,
        category: 'quizzes',
      ),
      Achievement(
        id: '3',
        title: 'Course Conqueror',
        description: 'Finish a full course',
        icon: Icons.auto_stories_rounded,
        color: Colors.blue,
        requiredCount: 1,
        category: 'courses',
      ),
      Achievement(
        id: '4',
        title: 'Mastery Achieved',
        description: 'Reach mastery level in a skill',
        icon: Icons.emoji_events_rounded,
        color: Colors.orange,
        requiredCount: 1,
        category: 'mastery',
      ),
    ];
  }

  // Helper methods to assign icons and colors based on category
  IconData _getIconForCategory(String? category) {
    switch (category) {
      case 'streak':
        return Icons.bolt_rounded;
      case 'courses':
        return Icons.auto_stories_rounded;
      case 'quizzes':
        return Icons.quiz_rounded;
      case 'mastery':
        return Icons.emoji_events_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  Color _getColorForCategory(String? category) {
    switch (category) {
      case 'streak':
        return Colors.orange;
      case 'courses':
        return Colors.blue;
      case 'quizzes':
        return Colors.purple;
      case 'mastery':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/achievement_model.dart';
import './notification_service.dart';
import '../../core/utils/haptic_utils.dart';

/// Service for managing achievements and gamification
class AchievementService extends GetxService {
  final _storage = GetStorage();
  final _key = 'achievements';
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  final achievements = <Achievement>[].obs;
  final unlockedCount = 0.obs;

  Future<AchievementService> init() async {
    _loadAchievements();
    return this;
  }

  void _loadAchievements() {
    final List<dynamic>? savedData = _storage.read(_key);
    if (savedData != null) {
      achievements.value = savedData.map((json) {
        return Achievement.fromJson(
          json,
          icon: _getIconForCategory(json['category']),
          color: _getColorForCategory(json['category']),
        );
      }).toList();
    } else {
      achievements.value = _getDefaultAchievements();
    }
    _updateUnlockedCount();
  }

  void _saveAchievements() {
    _storage.write(_key, achievements.map((a) => a.toJson()).toList());
  }

  void _updateUnlockedCount() {
    unlockedCount.value = achievements.where((a) => a.isUnlocked).length;
  }

  /// Update progress for an achievement
  void updateProgress(String achievementId, int progress) {
    final index = achievements.indexWhere((a) => a.id == achievementId);
    if (index == -1) return;

    final achievement = achievements[index];
    if (achievement.isUnlocked) return; // Already unlocked

    final updated = achievement.copyWith(currentProgress: progress);
    achievements[index] = updated;

    // Check if just unlocked
    if (updated.isCompleted && !updated.isUnlocked) {
      _unlockAchievement(achievementId);
    }

    _saveAchievements();
  }

  /// Increment progress for an achievement
  void incrementProgress(String achievementId, [int amount = 1]) {
    final achievement = achievements.firstWhereOrNull(
      (a) => a.id == achievementId,
    );
    if (achievement != null) {
      updateProgress(achievementId, achievement.currentProgress + amount);
    }
  }

  /// Unlock an achievement
  void _unlockAchievement(String achievementId) {
    final index = achievements.indexWhere((a) => a.id == achievementId);
    if (index == -1) return;

    final achievement = achievements[index];
    achievements[index] = achievement.copyWith(
      isUnlocked: true,
      unlockedAt: DateTime.now(),
    );

    _updateUnlockedCount();
    _saveAchievements();

    // Celebrate!
    HapticUtils.heavyImpact();
    _notificationService.showNotification(
      id: achievementId.hashCode,
      title: '🎉 Achievement Unlocked!',
      body: achievement.title,
    );

    Get.snackbar(
      '🎉 Achievement Unlocked!',
      achievement.title,
      snackPosition: SnackPosition.TOP,
      backgroundColor: achievement.color.withOpacity(0.9),
      colorText: Colors.white,
      icon: Icon(achievement.icon, color: Colors.white),
      duration: const Duration(seconds: 4),
    );
  }

  List<Achievement> _getDefaultAchievements() {
    return [
      Achievement(
        id: 'first_course',
        title: 'First Steps',
        description: 'Complete your first course',
        icon: Icons.school,
        color: Colors.blue,
        requiredCount: 1,
        category: 'courses',
      ),
      Achievement(
        id: 'course_master',
        title: 'Course Master',
        description: 'Complete 5 courses',
        icon: Icons.workspace_premium,
        color: Colors.purple,
        requiredCount: 5,
        category: 'courses',
      ),
      Achievement(
        id: 'quiz_novice',
        title: 'Quiz Novice',
        description: 'Complete 10 quizzes',
        icon: Icons.quiz,
        color: Colors.orange,
        requiredCount: 10,
        category: 'quizzes',
      ),
      Achievement(
        id: 'perfect_score',
        title: 'Perfect Score',
        description: 'Get 100% on a quiz',
        icon: Icons.star,
        color: Colors.amber,
        requiredCount: 1,
        category: 'quizzes',
      ),
      Achievement(
        id: 'week_streak',
        title: 'Dedicated Learner',
        description: 'Practice for 7 days in a row',
        icon: Icons.local_fire_department,
        color: Colors.red,
        requiredCount: 7,
        category: 'streak',
      ),
      Achievement(
        id: 'mastery_expert',
        title: 'Mastery Expert',
        description: 'Achieve 90%+ mastery in 3 topics',
        icon: Icons.emoji_events,
        color: Colors.green,
        requiredCount: 3,
        category: 'mastery',
      ),
    ];
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'courses':
        return Icons.school;
      case 'quizzes':
        return Icons.quiz;
      case 'streak':
        return Icons.local_fire_department;
      case 'mastery':
        return Icons.emoji_events;
      default:
        return Icons.star;
    }
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'courses':
        return Colors.blue;
      case 'quizzes':
        return Colors.orange;
      case 'streak':
        return Colors.red;
      case 'mastery':
        return Colors.green;
      default:
        return Colors.purple;
    }
  }
}

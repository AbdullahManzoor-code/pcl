import 'package:flutter/material.dart';

/// Achievement model for gamification
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int requiredCount;
  final String category; // 'courses', 'quizzes', 'streak', 'mastery'
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int currentProgress;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.requiredCount,
    required this.category,
    this.isUnlocked = false,
    this.unlockedAt,
    this.currentProgress = 0,
  });

  double get progress => currentProgress / requiredCount;
  bool get isCompleted => currentProgress >= requiredCount;

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    Color? color,
    int? requiredCount,
    String? category,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? currentProgress,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      requiredCount: requiredCount ?? this.requiredCount,
      category: category ?? this.category,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      currentProgress: currentProgress ?? this.currentProgress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'requiredCount': requiredCount,
      'category': category,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'currentProgress': currentProgress,
    };
  }

  factory Achievement.fromJson(
    Map<String, dynamic> json, {
    required IconData icon,
    required Color color,
  }) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: icon,
      color: color,
      requiredCount: json['requiredCount'],
      category: json['category'],
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
      currentProgress: json['currentProgress'] ?? 0,
    );
  }
}

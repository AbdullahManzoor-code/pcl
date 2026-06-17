import 'review_model.dart';
import 'topic_model.dart';

class Course {
  final String id;
  final String title;
  final String category;
  final String level;
  final String image;
  final double progress;
  final bool isCompleted;
  final bool isEnrolled;
  final String description;
  final double rating;
  final int reviewCount;
  final List<Review> reviews;
  final int accuracy;
  final int topicsCompleted;
  final int totalTopics;
  final double difficulty; // 0.0 - 1.0 (Easy, Medium, Hard)
  final String lastActivity;
  final String intensity; // Casual, Regular, Intense
  final List<Topic> topics;

  Course({
    required this.id,
    required this.title,
    required this.category,
    required this.level,
    required this.image,
    this.progress = 0.0,
    this.isCompleted = false,
    this.isEnrolled = false,
    this.description = '',
    this.rating = 0.0,
    this.reviewCount = 0,
    this.reviews = const [],
    this.accuracy = 0,
    this.topicsCompleted = 0,
    this.totalTopics = 0,
    this.difficulty = 0.5,
    this.lastActivity = 'Just now',
    this.intensity = 'Regular',
    this.topics = const [],
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    var reviewsList = <Review>[];
    if (json['reviews'] != null) {
      json['reviews'].forEach((v) {
        reviewsList.add(Review.fromJson(v));
      });
    }

    return Course(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      level: json['level'] ?? '',
      image: json['image'] ?? '',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['is_completed'] ?? false,
      isEnrolled: json['is_enrolled'] ?? false,
      description: json['description'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] ?? 0,
      reviews: reviewsList,
      accuracy: json['accuracy'] ?? 0,
      topicsCompleted: json['topics_completed'] ?? 0,
      totalTopics: json['total_topics'] ?? 0,
      difficulty: (json['difficulty'] as num?)?.toDouble() ?? 0.5,
      lastActivity: json['last_activity'] ?? 'Just now',
      intensity: json['intensity'] ?? 'Regular',
      topics:
          (json['topics'] as List?)?.map((e) => Topic.fromJson(e)).toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'level': level,
      'image': image,
      'progress': progress,
      'is_completed': isCompleted,
      'is_enrolled': isEnrolled,
      'description': description,
      'rating': rating,
      'review_count': reviewCount,
      'reviews': reviews.map((v) => v.toJson()).toList(),
      'accuracy': accuracy,
      'topics_completed': topicsCompleted,
      'total_topics': totalTopics,
      'last_activity': lastActivity,
      'difficulty': difficulty,
      'intensity': intensity,
      'topics': topics.map((v) => v.toJson()).toList(),
    };
  }

  Course copyWith({
    String? id,
    String? title,
    String? category,
    String? level,
    String? image,
    double? progress,
    bool? isCompleted,
    bool? isEnrolled,
    String? description,
    double? rating,
    int? reviewCount,
    List<Review>? reviews,
    int? accuracy,
    int? topicsCompleted,
    int? totalTopics,
    double? difficulty,
    String? lastActivity,
    String? intensity,
    List<Topic>? topics,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      level: level ?? this.level,
      image: image ?? this.image,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      reviews: reviews ?? this.reviews,
      accuracy: accuracy ?? this.accuracy,
      topicsCompleted: topicsCompleted ?? this.topicsCompleted,
      totalTopics: totalTopics ?? this.totalTopics,
      difficulty: difficulty ?? this.difficulty,
      lastActivity: lastActivity ?? this.lastActivity,
      intensity: intensity ?? this.intensity,
      topics: topics ?? this.topics,
    );
  }
}

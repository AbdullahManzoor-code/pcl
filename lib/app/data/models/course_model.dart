import 'review_model.dart';

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
    };
  }
}

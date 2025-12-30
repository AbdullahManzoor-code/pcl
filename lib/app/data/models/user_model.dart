class User {
  final String? name;
  final String? email;
  final String? profilePic;
  final String? bio;
  final UserStats? stats;

  User({this.name, this.email, this.profilePic, this.bio, this.stats});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      profilePic: json['profile_pic'],
      bio: json['bio'],
      stats: json['stats'] != null ? UserStats.fromJson(json['stats']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'profile_pic': profilePic,
      'bio': bio,
      'stats': stats?.toJson(),
    };
  }

  User copyWith({
    String? name,
    String? email,
    String? profilePic,
    String? bio,
    UserStats? stats,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      profilePic: profilePic ?? this.profilePic,
      bio: bio ?? this.bio,
      stats: stats ?? this.stats,
    );
  }
}

class UserStats {
  final int consecutiveDays;
  final int totalHours;
  final int completedCourses;
  final int totalXP;
  final List<String> badges;
  final int todayPoints;
  final int todayMinutes;

  UserStats({
    this.consecutiveDays = 0,
    this.totalHours = 0,
    this.completedCourses = 0,
    this.totalXP = 0,
    this.badges = const [],
    this.todayPoints = 0,
    this.todayMinutes = 0,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      consecutiveDays: json['consecutive_days'] ?? 0,
      totalHours: json['total_hours'] ?? 0,
      completedCourses: json['completed_courses'] ?? 0,
      totalXP: json['total_xp'] ?? 0,
      badges: List<String>.from(json['badges'] ?? []),
      todayPoints: json['today_points'] ?? 0,
      todayMinutes: json['today_minutes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'consecutive_days': consecutiveDays,
      'total_hours': totalHours,
      'completed_courses': completedCourses,
      'total_xp': totalXP,
      'badges': badges,
      'today_points': todayPoints,
      'today_minutes': todayMinutes,
    };
  }
}

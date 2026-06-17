class User {
  /// Real API fields
  final String? id;
  final String? email;
  final String? lastActiveLanguage;
  final int? totalExamsTaken;
  final DateTime? createdAt;
  final bool? isAdmin;
  final String? status;
  final String? phone;
  final String? altEmail;
  final String? profilePicUrl;

  /// Mock/Extended fields
  final String? name;
  final String? profilePic;
  final String? bio;
  final UserStats? stats;

  User({
    this.id,
    this.email,
    this.lastActiveLanguage,
    this.totalExamsTaken,
    this.createdAt,
    this.isAdmin,
    this.status,
    this.phone,
    this.altEmail,
    this.profilePicUrl,
    this.name,
    this.profilePic,
    this.bio,
    this.stats,
  });

  /// Factory to parse Real API login response
  factory User.fromLoginResponse(Map<String, dynamic> json) {
    return User(
      id: json['user_id'],
      email: json['email'],
      lastActiveLanguage: json['last_active_language'],
      isAdmin: json['is_admin'] ?? false,
      status: json['status'],
    );
  }

  /// Factory to parse Real API /auth/me response
  factory User.fromApiResponse(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      lastActiveLanguage: json['last_active_language'],
      totalExamsTaken: json['total_exams_taken'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      name: json['name'],
      phone: json['phone'],
      altEmail: json['alt_email'],
      profilePicUrl: json['profile_pic_url'],
    );
  }

  /// Factory for mock data (backward compatibility)
  factory User.fromJson(Map<String, dynamic> json) {
    // Check if this is real API response (has 'user_id' or 'id' without 'name')
    if ((json.containsKey('user_id') || json.containsKey('id')) &&
        !json.containsKey('name')) {
      if (json.containsKey('user_id')) {
        return User.fromLoginResponse(json);
      } else {
        return User.fromApiResponse(json);
      }
    }

    // Otherwise, treat as mock data
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
      'id': id,
      'user_id': id, // for backward compatibility with login response
      'email': email,
      'last_active_language': lastActiveLanguage,
      'total_exams_taken': totalExamsTaken,
      'created_at': createdAt?.toIso8601String(),
      'is_admin': isAdmin,
      'status': status,
      'name': name,
      'phone': phone,
      'alt_email': altEmail,
      'profile_pic_url': profilePicUrl,
      'profile_pic': profilePic,
      'bio': bio,
      'stats': stats?.toJson(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? lastActiveLanguage,
    int? totalExamsTaken,
    DateTime? createdAt,
    bool? isAdmin,
    String? status,
    String? name,
    String? phone,
    String? altEmail,
    String? profilePicUrl,
    String? profilePic,
    String? bio,
    UserStats? stats,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      lastActiveLanguage: lastActiveLanguage ?? this.lastActiveLanguage,
      totalExamsTaken: totalExamsTaken ?? this.totalExamsTaken,
      createdAt: createdAt ?? this.createdAt,
      isAdmin: isAdmin ?? this.isAdmin,
      status: status ?? this.status,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      altEmail: altEmail ?? this.altEmail,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      profilePic: profilePic ?? this.profilePic,
      bio: bio ?? this.bio,
      stats: stats ?? this.stats,
    );
  }

  /// Merge real API user with mock data (name, stats, bio)
  User mergeWithMockData({
    required String? mockName,
    required String? mockProfilePic,
    required String? mockBio,
    required UserStats? mockStats,
  }) {
    return User(
      id: id,
      email: email,
      lastActiveLanguage: lastActiveLanguage,
      totalExamsTaken: totalExamsTaken,
      createdAt: createdAt,
      isAdmin: isAdmin,
      status: status,
      name: mockName ?? name,
      phone: phone,
      altEmail: altEmail,
      profilePicUrl: mockProfilePic ?? profilePicUrl,
      profilePic: mockProfilePic ?? profilePic,
      bio: mockBio ?? bio,
      stats: mockStats ?? stats,
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

  /// Create default static stats for new users (Real API doesn't provide stats)
  /// These are static/hardcoded values since real API doesn't include stats data
  factory UserStats.defaultMock() {
    return UserStats(
      consecutiveDays: 0,
      totalHours: 0,
      completedCourses: 0,
      totalXP: 0,
      badges: const [],
      todayPoints: 0,
      todayMinutes: 0,
    );
  }

  /// Create initial stats for new authenticated user
  /// Used when user logs in via real API (which doesn't provide stats)
  factory UserStats.forNewUser() {
    return UserStats(
      consecutiveDays: 0,
      totalHours: 0,
      completedCourses: 0,
      totalXP: 0,
      badges: const ['New User'],
      todayPoints: 0,
      todayMinutes: 0,
    );
  }

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

  UserStats copyWith({
    int? consecutiveDays,
    int? totalHours,
    int? completedCourses,
    int? totalXP,
    List<String>? badges,
    int? todayPoints,
    int? todayMinutes,
  }) {
    return UserStats(
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      totalHours: totalHours ?? this.totalHours,
      completedCourses: completedCourses ?? this.completedCourses,
      totalXP: totalXP ?? this.totalXP,
      badges: badges ?? this.badges,
      todayPoints: todayPoints ?? this.todayPoints,
      todayMinutes: todayMinutes ?? this.todayMinutes,
    );
  }
}

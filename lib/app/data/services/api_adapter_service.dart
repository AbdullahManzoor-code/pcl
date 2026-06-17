import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user_model.dart';

/// Adapter service to handle conversion between Real API and Mock data
/// Handles the data structure mismatch between Real API and Flutter mock implementation
class ApiAdapterService extends GetxService {
  final _storage = GetStorage();

  static const String _mockUserKey = 'mock_user_data';
  static const String _realUserKey = 'real_user_data';
  static const String _mergedUserKey = 'merged_user_data';

  /// Convert Real API login response to User model and merge with mock data
  User convertLoginResponse(Map<String, dynamic> apiResponse) {
    // Parse real API response
    final user = User.fromLoginResponse(apiResponse);

    // Get stored mock data (if any)
    final mockUserData = _storage.read(_mockUserKey);
    String? mockName;
    String? mockProfilePic;
    String? mockBio;
    UserStats? mockStats;

    if (mockUserData != null) {
      final mockData = Map<String, dynamic>.from(mockUserData);
      mockName = mockData['name'];
      mockProfilePic = mockData['profile_pic'];
      mockBio = mockData['bio'];
      if (mockData['stats'] != null) {
        mockStats = UserStats.fromJson(mockData['stats']);
      }
    }

    // Merge real API data with mock data
    final mergedUser = user.mergeWithMockData(
      mockName: mockName,
      mockProfilePic: mockProfilePic,
      mockBio: mockBio,
      mockStats: mockStats ?? UserStats.defaultMock(),
    );

    // Store merged user data
    _storage.write(_mergedUserKey, mergedUser.toJson());

    return mergedUser;
  }

  /// Convert Real API /auth/me response to User model
  User convertProfileResponse(Map<String, dynamic> apiResponse) {
    // Parse real API response
    final user = User.fromApiResponse(apiResponse);

    // Get stored mock data
    final mockUserData = _storage.read(_mockUserKey);
    String? mockName;
    String? mockProfilePic;
    String? mockBio;
    UserStats? mockStats;

    if (mockUserData != null) {
      final mockData = Map<String, dynamic>.from(mockUserData);
      mockName = mockData['name'];
      mockProfilePic = mockData['profile_pic'];
      mockBio = mockData['bio'];
      if (mockData['stats'] != null) {
        mockStats = UserStats.fromJson(mockData['stats']);
      }
    }

    // Merge real API data with mock data
    final mergedUser = user.mergeWithMockData(
      mockName: mockName,
      mockProfilePic: mockProfilePic,
      mockBio: mockBio,
      mockStats: mockStats ?? UserStats.defaultMock(),
    );

    // Store merged user data
    _storage.write(_mergedUserKey, mergedUser.toJson());

    return mergedUser;
  }

  /// Store mock user data separately (for name, bio, stats)
  void saveMockUserData(User user) {
    final mockData = {
      'name': user.name,
      'profile_pic': user.profilePic,
      'bio': user.bio,
      'stats': user.stats?.toJson(),
    };
    _storage.write(_mockUserKey, mockData);
  }

  /// Get last stored merged user (for offline support)
  User? getMergedUser() {
    final mergedData = _storage.read(_mergedUserKey);
    if (mergedData != null) {
      return User.fromJson(mergedData);
    }
    return null;
  }

  /// Update user stats in local mock data
  void updateUserStats(UserStats stats) {
    final mockUserData = _storage.read(_mockUserKey) ?? {};
    final updatedData = Map<String, dynamic>.from(mockUserData);
    updatedData['stats'] = stats.toJson();
    _storage.write(_mockUserKey, updatedData);

    // Also update merged user
    final mergedUser = getMergedUser();
    if (mergedUser != null) {
      final updatedMergedUser = mergedUser.copyWith(stats: stats);
      _storage.write(_mergedUserKey, updatedMergedUser.toJson());
    }
  }

  /// Clear all stored user data
  void clearUserData() {
    _storage.remove(_mockUserKey);
    _storage.remove(_realUserKey);
    _storage.remove(_mergedUserKey);
  }
}

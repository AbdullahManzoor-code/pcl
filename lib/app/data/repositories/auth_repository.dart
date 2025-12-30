import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/mock_api_service.dart';

abstract class AuthRepository {
  Future<User?> login(String email, String password);
  Future<User?> socialLogin(String provider);
  Future<void> register(String name, String email, String password);
  Future<void> logout();
  Future<User?> getCurrentUser();
}

class AuthRepositoryImpl implements AuthRepository {
  final MockApiService _apiService;

  AuthRepositoryImpl(this._apiService);

  @override
  Future<User?> login(String email, String password) async {
    final userData = await _apiService.login(email, password);
    return User.fromJson(userData);
  }

  @override
  Future<User?> socialLogin(String provider) async {
    final userData = await _apiService.socialLogin(provider);
    return User.fromJson(userData);
  }

  @override
  Future<void> register(String name, String email, String password) async {
    // Mock registration logic
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> logout() async {
    // Mock logout logic
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final userStats = _apiService.getUserStats();
      // Since mock service doesn't easily expose full user on refresh without login,
      // we'll mock a "check session" by calling login silently or just returning null
      // In a real app, we'd check token.
      // For now, let's assume we can get the cached user from service if exposed.
      // But _user is private.
      // Workaround: We will update this when we refactor MockApiService to Models.
      // For now returning null or a default mock user if needed.
      return null;
    } catch (e) {
      return null;
    }
  }
}

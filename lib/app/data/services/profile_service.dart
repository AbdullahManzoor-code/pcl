import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/profile_stats_model.dart';
import '../models/course_api_models.dart';
import 'auth_service.dart';
import 'api_config.dart';
import 'network_error_handler.dart';
import '../../core/utils/app_logger.dart';

/// Aggregates data from multiple endpoints to build the complete ProfileStats.
/// Endpoints used:
///   GET /api/user/languages        → language portfolio
///   GET /api/dashboard/summary     → mastery, decay alerts, recent sessions
class ProfileService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();
  final GetStorage _storage = GetStorage();

  static String get _base => ApiConfig.baseUrl;
  static const _cacheKey = 'cache_profile_stats';
  static const _cacheTtlMinutes = 5;

  Map<String, String> get _headers {
    final token = _authService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Fetch and aggregate full profile stats.
  Future<ProfileStats> getProfileStats() async {
    AppLogger.info('ProfileService.getProfileStats(): start');

    // ── 1. Language portfolio ──────────────────────────
    LanguagePortfolio? portfolio;
    try {
      final res = await http
          .get(Uri.parse('$_base/api/user/languages'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        portfolio = LanguagePortfolio.fromJson(jsonDecode(res.body));
        AppLogger.info(
          'ProfileService.getProfileStats(): portfolio loaded languages=${portfolio.totalLanguages}',
        );
      }
    } catch (e) {
      AppLogger.warning(
        'ProfileService.getProfileStats(): portfolio fetch failed, using cache',
      );
      final cached = _storage.read('cache_user_languages');
      if (cached != null) {
        try {
          portfolio = LanguagePortfolio.fromJson(jsonDecode(cached));
        } catch (_) {}
      }
    }

    // ── 2. Dashboard summary for primary language ──────
    DashboardSummary? dashboard;
    final primaryLang =
        portfolio?.primaryLanguage ??
        portfolio?.languages.firstOrNull?.languageId;

    if (primaryLang != null) {
      try {
        final res = await http
            .get(
              Uri.parse('$_base/api/dashboard/summary?language_id=$primaryLang'),
              headers: _headers,
            )
            .timeout(const Duration(seconds: 12));
        if (res.statusCode == 200) {
          dashboard = DashboardSummary.fromJson(jsonDecode(res.body));
          AppLogger.info(
            'ProfileService.getProfileStats(): dashboard loaded '
            'mastery=${dashboard.masteryData.length} '
            'alerts=${dashboard.decayAlerts.length} '
            'sessions=${dashboard.recentSessions.length}',
          );
        }
      } catch (e) {
        AppLogger.warning(
          'ProfileService.getProfileStats(): dashboard fetch failed: $e',
        );
      }
    }

    // ── 3. Aggregate cross-language stats ──────────────
    int totalSessions = 0;
    int totalTopicsCompleted = 0;
    double totalAccuracySum = 0.0;
    int accuracyCount = 0;
    String? lastActivity;

    if (portfolio != null) {
      for (final lang in portfolio.languages) {
        totalSessions += lang.totalSessions;
        totalTopicsCompleted += lang.topicsCompleted;
        if (lang.avgAccuracy > 0) {
          totalAccuracySum += lang.avgAccuracy;
          accuracyCount++;
        }
        if (lang.lastPracticed != null) {
          if (lastActivity == null ||
              lang.lastPracticed!.compareTo(lastActivity) > 0) {
            lastActivity = lang.lastPracticed;
          }
        }
      }
    }

    final overallAccuracy =
        accuracyCount > 0 ? totalAccuracySum / accuracyCount : 0.0;

    return ProfileStats.fromAggregated(
      totalSessions: totalSessions,
      totalTopicsCompleted: totalTopicsCompleted,
      overallAccuracy: overallAccuracy,
      languagesCount: portfolio?.totalLanguages ?? 0,
      primaryLanguage: portfolio?.primaryLanguage,
      lastActivityDate: lastActivity,
      masteryData: dashboard?.masteryData ?? [],
      decayAlerts: dashboard?.decayAlerts ?? [],
      recentSessions: dashboard?.recentSessions ?? [],
    );
  }
}

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user_model.dart';

/// Service to handle UI-specific cosmetic data that the Real API doesn't provide.
class LocalProfileService extends GetxService {
  final _storage = GetStorage();

  String? get name => _storage.read('ui_name');
  String? get profilePic => _storage.read('ui_profilePic');
  String? get bio => _storage.read('ui_bio');
  Map<String, dynamic>? get statsData => _storage.read('ui_stats');

  void saveProfile({String? name, String? profilePic, String? bio}) {
    if (name != null) _storage.write('ui_name', name);
    if (profilePic != null) _storage.write('ui_profilePic', profilePic);
    if (bio != null) _storage.write('ui_bio', bio);
  }

  void saveStats(UserStats stats) {
    _storage.write('ui_stats', stats.toJson());
  }

  User mergeWithRealUser(User realUser) {
    final sData = statsData;
    return realUser.copyWith(
      name: name ?? realUser.name,
      profilePic: profilePic ?? realUser.profilePic,
      bio: bio ?? realUser.bio,
      stats: sData != null ? UserStats.fromJson(sData) : UserStats.defaultMock(),
    );
  }

  void clear() {
    _storage.remove('ui_name');
    _storage.remove('ui_profilePic');
    _storage.remove('ui_bio');
    _storage.remove('ui_stats');
  }
}

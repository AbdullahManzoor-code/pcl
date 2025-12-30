import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/mock_api_service.dart';

class ProfileController extends GetxController {
  late final AuthRepository _authRepository;

  final user = Rxn<User>();
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    // In real app, inject this
    _authRepository = AuthRepositoryImpl(Get.find<MockApiService>());
    fetchProfile();
  }

  void fetchProfile() async {
    isLoading.value = true;
    try {
      final mockUser = await _authRepository.login('mock', 'mock');
      user.value = mockUser;
    } catch (e) {
      print('Error fetching profile: $e');
      Get.snackbar(
        'Error',
        'Failed to load profile data.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile({String? name, String? bio}) async {
    if (user.value == null) return;

    // Validation
    if (name != null && name.trim().isEmpty) {
      Get.snackbar('Validation', 'Name cannot be empty');
      return;
    }

    isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final mockApi = Get.find<MockApiService>();
      if (name != null) mockApi.updateProfile(name.trim());
      if (bio != null) mockApi.updateBio(bio ?? '');

      // Fix null-safety warning by assigning to a local non-nullable variable
      final currentUser = user.value!;
      user.value = currentUser.copyWith(
        name: name?.trim() ?? currentUser.name,
        bio: bio ?? currentUser.bio,
      );

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../profile/services/profile_service.dart';
import '../api_models.dart';

class ProfileController extends GetxController {
  final Rx<ProfileModel?> profile = Rx<ProfileModel?>(null);
  final RxBool isLoading = false.obs;
  final _profileService = ProfileService();

  String get appTitle {
    if (profile.value != null) {
      return '${profile.value!.tenant.name} - ${profile.value!.branch.name}';
    }
    return 'MyPOSMobile';
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final response = await _profileService.getProfile();

      if (response.statusCode == 200 && response.data != null) {
        profile.value = response.data;
        debugPrint('Profile fetched: ${response.data!.user.fullName}');
      }
    } catch (e) {
      debugPrint('Failed to fetch profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void clearProfile() {
    profile.value = null;
  }
}

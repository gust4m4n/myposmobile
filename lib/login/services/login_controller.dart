import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/controllers/auth_controller.dart';
import '../../shared/controllers/profile_controller.dart';
import '../../shared/services/sync_integration_service.dart';
import 'login_service.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final loginService = LoginService();

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    if (formKey.currentState?.validate() != true) {
      return;
    }

    isLoading.value = true;

    final response = await loginService.login(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    isLoading.value = false;

    if (response.statusCode == 200 && response.data != null) {
      // Get auth controller and update token
      final authController = Get.find<AuthController>();
      await authController.login(response.data!.token);

      // Fetch profile
      final profileController = Get.find<ProfileController>();
      await profileController.fetchProfile();

      // Perform initial sync after successful login
      try {
        final syncService = Get.find<SyncIntegrationService>();
        // Run sync in background without blocking UI
        syncService
            .performFullSync()
            .then((result) {
              if (result['success'] == true) {
                print(
                  'Initial sync completed: ${result['uploaded']} uploaded, ${result['downloaded']} downloaded',
                );
              }
            })
            .catchError((error) {
              print('Initial sync failed: $error');
              // Don't show error to user, sync will retry later
            });
      } catch (e) {
        print('Sync service not available: $e');
      }

      // Navigation will be handled automatically by GetX bindings
    } else {
      Get.snackbar(
        'Login Failed',
        response.error ?? 'Unknown error',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFF453A),
        colorText: Colors.white,
      );
    }
  }
}

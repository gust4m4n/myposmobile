import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../shared/controllers/auth_controller.dart';
import '../shared/controllers/profile_controller.dart';
import 'dev_branches_service.dart';
import 'dev_tenants_service.dart';
import 'login_service.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final loginService = LoginService();

  final RxBool isLoading = false.obs;
  final RxBool isLoadingTenants = false.obs;
  final RxBool isLoadingBranches = false.obs;
  final RxBool obscurePassword = true.obs;

  final RxList<Map<String, dynamic>> tenants = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> branches = <Map<String, dynamic>>[].obs;
  final Rx<Map<String, dynamic>?> selectedTenant = Rx<Map<String, dynamic>?>(
    null,
  );
  final Rx<Map<String, dynamic>?> selectedBranch = Rx<Map<String, dynamic>?>(
    null,
  );

  @override
  void onInit() {
    super.onInit();
    loadTenants();
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> loadTenants() async {
    isLoadingTenants.value = true;

    final response = await DevTenantsService.getDevTenants();

    if (response.statusCode == 200 && response.data != null) {
      tenants.value = response.data!;
    }

    isLoadingTenants.value = false;
  }

  Future<void> loadBranches(int tenantId) async {
    isLoadingBranches.value = true;
    selectedBranch.value = null;
    branches.value = [];

    final response = await DevBranchesService.getDevBranches(tenantId);

    if (response.statusCode == 200 && response.data != null) {
      branches.value = response.data!;
    }

    isLoadingBranches.value = false;
  }

  Future<void> login() async {
    if (formKey.currentState?.validate() != true) {
      return;
    }

    if (selectedTenant.value == null) {
      Get.snackbar(
        'Error',
        'Please select a tenant',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFF453A),
        colorText: Colors.white,
      );
      return;
    }

    if (selectedBranch.value == null) {
      Get.snackbar(
        'Error',
        'Please select a branch',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFF453A),
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    final response = await loginService.login(
      tenantCode: selectedTenant.value!['code'] as String,
      branchCode: selectedBranch.value!['code'] as String,
      username: usernameController.text.trim(),
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

import 'package:get/get.dart';

import '../utils/api_x.dart';
import '../utils/storage_service.dart';

class AuthController extends GetxController {
  final Rx<String?> authToken = Rx<String?>(null);
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedToken();
  }

  Future<void> _loadSavedToken() async {
    final storage = await StorageService.getInstance();
    final savedToken = storage.getToken();

    authToken.value = savedToken;
    isLoading.value = false;

    // Set token to ApiX if exists
    if (savedToken != null) {
      ApiX.setAuthToken(savedToken);
    }

    // Set login success callback for 401 handling
    ApiX.setLoginSuccessCallback((token) {
      authToken.value = token;
    });
  }

  Future<void> login(String token) async {
    authToken.value = token;

    // Save token to storage
    final storage = await StorageService.getInstance();
    await storage.saveToken(token);

    // Set token to ApiX
    ApiX.setAuthToken(token);
  }

  Future<void> logout() async {
    authToken.value = null;

    // Clear token from storage and ApiX
    final storage = await StorageService.getInstance();
    await storage.clearToken();
    ApiX.clearAuthToken();
  }

  bool get isAuthenticated => authToken.value != null;
}

import '../shared/api_models.dart';
import '../shared/config/api_config.dart';
import '../shared/utils/api_x.dart';

class PinService {
  /// Create 6-digit PIN for user
  static Future<ApiResponse<Map<String, dynamic>>> createPin({
    required String pin,
    required String confirmPin,
  }) async {
    return await ApiX.post(
      ApiConfig.pinCreate,
      body: {'pin': pin, 'confirm_pin': confirmPin},
      requiresAuth: true,
    );
  }

  /// Change existing PIN
  static Future<ApiResponse<Map<String, dynamic>>> changePin({
    required String oldPin,
    required String newPin,
    required String confirmPin,
  }) async {
    return await ApiX.put(
      ApiConfig.pinChange,
      body: {'old_pin': oldPin, 'new_pin': newPin, 'confirm_pin': confirmPin},
      requiresAuth: true,
    );
  }

  /// Check if user has set a PIN
  static Future<ApiResponse<Map<String, dynamic>>> checkPinStatus() async {
    return await ApiX.get(ApiConfig.pinCheck, requiresAuth: true);
  }
}

import '../../shared/api_models.dart';
import '../../shared/utils/api_x.dart';

class PinService {
  /// Create 6-digit PIN for user
  static Future<ApiResponse<Map<String, dynamic>>> createPin({
    required String pin,
    required String confirmPin,
  }) async {
    return await ApiX.post(
      '/pin/create',
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
      '/pin/change',
      body: {'old_pin': oldPin, 'new_pin': newPin, 'confirm_pin': confirmPin},
      requiresAuth: true,
    );
  }

  /// Check if user has set a PIN
  static Future<ApiResponse<Map<String, dynamic>>> checkPinStatus() async {
    return await ApiX.get('/pin/check', requiresAuth: true);
  }

  /// Admin change PIN for another user (Admin only)
  static Future<ApiResponse<Map<String, dynamic>>> adminChangePin({
    required String username,
    required String pin,
    required String confirmPin,
  }) async {
    return await ApiX.put(
      '/admin/change-pin',
      body: {'username': username, 'pin': pin, 'confirm_pin': confirmPin},
      requiresAuth: true,
    );
  }
}

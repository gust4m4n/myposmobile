import '../../shared/api_models.dart';
import '../../shared/utils/api_x.dart';

class AdminChangePasswordService {
  /// PUT /api/v1/admin/change-password
  /// Admin change password for another user
  /// Requires higher role than target user
  ///
  /// Parameters:
  /// - email: Email of user to change password
  /// - password: New password
  /// - confirmPassword: Confirm new password
  ///
  /// Returns: ApiResponse with success message
  static Future<ApiResponse<Map<String, dynamic>>> adminChangePassword({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    return await ApiX.put(
      '/api/v1/admin/change-password',
      body: {
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
      },
      requiresAuth: true,
    );
  }
}

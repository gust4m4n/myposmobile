import '../../shared/api_models.dart';
import '../../shared/utils/api_x.dart';

class ChangePasswordService {
  /// PUT /api/v1/change-password
  /// Change password for current logged in user
  /// Requires JWT token
  ///
  /// Parameters:
  /// - oldPassword: Current password
  /// - newPassword: New password
  ///
  /// Returns: ApiResponse with success message
  Future<ApiResponse<void>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    return ApiX.put<void>(
      '/change-password',
      body: {'old_password': oldPassword, 'new_password': newPassword},
      requiresAuth: true,
    );
  }
}

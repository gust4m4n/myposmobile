import 'dart:convert';

import '../config/api_config.dart';
import '../models/api_models.dart';
import '../utils/http_client.dart';

class ChangePasswordService {
  final HttpClient _httpClient = HttpClient();

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
    try {
      final response = await _httpClient.put(
        ApiConfig.changePassword,
        body: {'old_password': oldPassword, 'new_password': newPassword},
        requiresAuth: true,
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse(
          message: jsonResponse['message'] ?? 'Password changed successfully',
        );
      } else {
        return ApiResponse(
          error: jsonResponse['error'] ?? 'Failed to change password',
        );
      }
    } catch (e) {
      return ApiResponse(error: 'Error changing password: $e');
    }
  }
}

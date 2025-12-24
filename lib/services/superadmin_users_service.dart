import 'dart:convert';

import '../config/api_config.dart';
import '../models/api_models.dart';
import '../utils/http_client.dart';

class SuperadminUsersService {
  final HttpClient _httpClient = HttpClient();

  /// GET /api/v1/superadmin/branches/:branch_id/users
  /// Get list of users for a specific branch
  /// Requires JWT token with superadmin role
  ///
  /// Parameters:
  /// - branchId: ID of the branch
  ///
  /// Returns: List of UserModel
  Future<ApiResponse<List<UserModel>>> listUsersByBranch(int branchId) async {
    try {
      final response = await _httpClient.get(
        ApiConfig.superadminBranchUsers(branchId),
        requiresAuth: true,
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> usersJson = jsonResponse['data'] ?? [];
        final users = usersJson
            .map((json) => UserModel.fromJson(json))
            .toList();

        return ApiResponse(message: jsonResponse['message'], data: users);
      } else {
        return ApiResponse(
          error: jsonResponse['error'] ?? 'Failed to list users',
        );
      }
    } catch (e) {
      return ApiResponse(error: 'Error listing users: $e');
    }
  }
}

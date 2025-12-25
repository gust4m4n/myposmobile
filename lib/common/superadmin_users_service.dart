import '../shared/api_models.dart';
import '../shared/config/api_config.dart';
import '../shared/utils/api_x.dart';

class SuperadminUsersService {
  /// GET /api/v1/superadmin/branches/:branch_id/users
  /// Get list of users for a specific branch
  /// Requires JWT token with superadmin role
  ///
  /// Parameters:
  /// - branchId: ID of the branch
  ///
  /// Returns: List of UserModel
  Future<ApiResponse<List<UserModel>>> listUsersByBranch(int branchId) async {
    return await ApiX.get(
      ApiConfig.superadminBranchUsers(branchId),
      requiresAuth: true,
      fromJson: (data) =>
          (data as List).map((json) => UserModel.fromJson(json)).toList(),
    );
  }
}

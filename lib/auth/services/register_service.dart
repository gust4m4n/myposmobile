import '../../shared/api_models.dart';
import '../../shared/config/api_config.dart';
import '../../shared/utils/api_x.dart';

class RegisterService {
  /// POST /api/v1/auth/register
  /// Register a new user
  ///
  /// Parameters:
  /// - tenantCode: Tenant code
  /// - branchCode: Branch code
  /// - username: Username
  /// - email: Email address
  /// - password: Password
  /// - fullName: Full name
  ///
  /// Returns: AuthResponseData with token and user info
  Future<ApiResponse<AuthResponseData>> register({
    required String tenantCode,
    required String branchCode,
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    return await ApiX.post(
      ApiConfig.register,
      body: {
        'tenant_code': tenantCode,
        'branch_code': branchCode,
        'username': username,
        'email': email,
        'password': password,
        'full_name': fullName,
      },
      fromJson: (json) => AuthResponseData.fromJson(json),
    );
  }
}

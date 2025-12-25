import '../shared/api_models.dart';
import '../shared/config/api_config.dart';
import '../shared/utils/api_x.dart';

class LoginService {
  /// POST /api/v1/auth/login
  /// Login user and get JWT token
  ///
  /// Parameters:
  /// - tenantCode: Tenant code
  /// - branchCode: Branch code
  /// - username: Username
  /// - password: Password
  ///
  /// Returns: AuthResponseData with token and user info
  Future<ApiResponse<AuthResponseData>> login({
    required String tenantCode,
    required String branchCode,
    required String username,
    required String password,
  }) async {
    final response = await ApiX.post<AuthResponseData>(
      ApiConfig.login,
      body: {
        'tenant_code': tenantCode,
        'branch_code': branchCode,
        'username': username,
        'password': password,
      },
      fromJson: (data) => AuthResponseData.fromJson(data),
    );

    // Save token to ApiX
    if (response.data?.token != null) {
      ApiX.setAuthToken(response.data!.token);
    }

    return response;
  }

  /// Logout user and clear token
  void logout() {
    ApiX.clearAuthToken();
  }
}

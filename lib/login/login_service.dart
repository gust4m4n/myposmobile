import '../shared/api_models.dart';
import '../shared/config/api_config.dart';
import '../shared/utils/api_x.dart';

class LoginService {
  /// POST /api/v1/auth/login
  /// Login user and get JWT token
  ///
  /// Parameters:
  /// - email: Email (unique across system)
  /// - password: Password
  ///
  /// Returns: AuthResponseData with token, user, tenant, and branch info
  Future<ApiResponse<AuthResponseData>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiX.post<AuthResponseData>(
      ApiConfig.login,
      body: {'email': email, 'password': password},
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

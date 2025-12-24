import 'dart:convert';

import '../config/api_config.dart';
import '../models/api_models.dart';
import '../utils/http_client.dart';

class LoginService {
  final HttpClient _httpClient = HttpClient();

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
    try {
      final response = await _httpClient.post(
        ApiConfig.login,
        body: {
          'tenant_code': tenantCode,
          'branch_code': branchCode,
          'username': username,
          'password': password,
        },
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          jsonResponse,
          (data) => AuthResponseData.fromJson(data),
        );

        // Save token to HttpClient
        if (apiResponse.data?.token != null) {
          _httpClient.setAuthToken(apiResponse.data!.token);
        }

        return apiResponse;
      } else {
        return ApiResponse(error: jsonResponse['error'] ?? 'Login failed');
      }
    } catch (e) {
      return ApiResponse(error: 'Error during login: $e');
    }
  }

  /// Logout user and clear token
  void logout() {
    _httpClient.clearAuthToken();
  }
}

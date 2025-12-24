import 'dart:convert';

import '../config/api_config.dart';
import '../models/api_models.dart';
import '../utils/http_client.dart';

class RegisterService {
  final HttpClient _httpClient = HttpClient();

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
    try {
      final response = await _httpClient.post(
        ApiConfig.register,
        body: {
          'tenant_code': tenantCode,
          'branch_code': branchCode,
          'username': username,
          'email': email,
          'password': password,
          'full_name': fullName,
        },
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 201) {
        return ApiResponse.fromJson(
          jsonResponse,
          (data) => AuthResponseData.fromJson(data),
        );
      } else {
        return ApiResponse(
          error: jsonResponse['error'] ?? 'Registration failed',
        );
      }
    } catch (e) {
      return ApiResponse(error: 'Error during registration: $e');
    }
  }
}

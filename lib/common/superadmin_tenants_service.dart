import 'dart:convert';

import '../shared/api_models.dart';
import '../shared/config/api_config.dart';
import '../shared/utils/http_client.dart';

class SuperadminTenantsService {
  final HttpClient _httpClient = HttpClient();

  /// GET /api/v1/superadmin/tenants
  /// Get list of all tenants
  /// Requires JWT token with superadmin role
  ///
  /// Returns: List of TenantModel
  Future<ApiResponse<List<TenantModel>>> listTenants() async {
    try {
      final response = await _httpClient.get(
        ApiConfig.superadminTenants,
        requiresAuth: true,
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> tenantsJson = jsonResponse['data'] ?? [];
        final tenants = tenantsJson
            .map((json) => TenantModel.fromJson(json))
            .toList();

        return ApiResponse(message: jsonResponse['message'], data: tenants);
      } else {
        return ApiResponse(
          error: jsonResponse['error'] ?? 'Failed to list tenants',
        );
      }
    } catch (e) {
      return ApiResponse(error: 'Error listing tenants: $e');
    }
  }

  /// POST /api/v1/superadmin/tenants
  /// Create a new tenant
  /// Requires JWT token with superadmin role
  ///
  /// Parameters:
  /// - name: Tenant name
  /// - code: Tenant code (unique)
  /// - isActive: Active status (default: true)
  ///
  /// Returns: Created TenantModel
  Future<ApiResponse<TenantModel>> createTenant({
    required String name,
    required String code,
    bool isActive = true,
  }) async {
    try {
      final response = await _httpClient.post(
        ApiConfig.superadminTenants,
        body: {'name': name, 'code': code, 'is_active': isActive},
        requiresAuth: true,
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 201) {
        return ApiResponse.fromJson(
          jsonResponse,
          (data) => TenantModel.fromJson(data),
        );
      } else {
        return ApiResponse(
          error: jsonResponse['error'] ?? 'Failed to create tenant',
        );
      }
    } catch (e) {
      return ApiResponse(error: 'Error creating tenant: $e');
    }
  }
}

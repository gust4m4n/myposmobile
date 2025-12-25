import '../shared/api_models.dart';
import '../shared/config/api_config.dart';
import '../shared/utils/api_x.dart';

class SuperadminTenantsService {
  /// GET /api/v1/superadmin/tenants
  /// Get list of all tenants
  /// Requires JWT token with superadmin role
  ///
  /// Returns: List of TenantModel
  Future<ApiResponse<List<TenantModel>>> listTenants() async {
    return await ApiX.get(
      ApiConfig.superadminTenants,
      requiresAuth: true,
      fromJson: (data) =>
          (data as List).map((json) => TenantModel.fromJson(json)).toList(),
    );
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
    return await ApiX.post(
      ApiConfig.superadminTenants,
      body: {'name': name, 'code': code, 'is_active': isActive},
      requiresAuth: true,
      fromJson: (json) => TenantModel.fromJson(json),
    );
  }
}

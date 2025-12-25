import '../shared/api_models.dart';
import '../shared/config/api_config.dart';
import '../shared/utils/api_x.dart';

class SuperadminBranchesService {
  /// GET /api/v1/superadmin/tenants/:tenant_id/branches
  /// Get list of branches for a specific tenant
  /// Requires JWT token with superadmin role
  ///
  /// Parameters:
  /// - tenantId: ID of the tenant
  ///
  /// Returns: List of BranchModel
  Future<ApiResponse<List<BranchModel>>> listBranchesByTenant(
    int tenantId,
  ) async {
    return await ApiX.get(
      ApiConfig.superadminTenantBranches(tenantId),
      requiresAuth: true,
      fromJson: (data) =>
          (data as List).map((json) => BranchModel.fromJson(json)).toList(),
    );
  }
}

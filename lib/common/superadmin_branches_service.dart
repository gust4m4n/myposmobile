import '../shared/api_models.dart';
import '../shared/config/api_config.dart';
import '../shared/utils/api_x.dart';

class SuperadminBranchesService {
  /// GET /api/v1/superadmin/tenants/:tenant_id/branches
  /// Get list of branches for a specific tenant with optional pagination
  /// Requires JWT token with superadmin role
  ///
  /// Parameters:
  /// - tenantId: ID of the tenant
  /// - page: Page number (optional)
  /// - pageSize: Items per page (optional)
  ///
  /// Returns: List of BranchModel
  Future<ApiResponse<List<BranchModel>>> listBranchesByTenant(
    int tenantId, {
    int? page,
    int? pageSize,
  }) async {
    String url = ApiConfig.superadminTenantBranches(tenantId);
    final queryParams = <String>[];

    if (page != null) queryParams.add('page=$page');
    if (pageSize != null) queryParams.add('page_size=$pageSize');

    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    return await ApiX.get(
      url,
      requiresAuth: true,
      fromJson: (data) =>
          (data as List).map((json) => BranchModel.fromJson(json)).toList(),
    );
  }
}

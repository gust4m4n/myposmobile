import 'dart:convert';

import '../shared/api_models.dart';
import '../shared/config/api_config.dart';
import '../shared/utils/http_client.dart';

class SuperadminBranchesService {
  final HttpClient _httpClient = HttpClient();

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
    try {
      final response = await _httpClient.get(
        ApiConfig.superadminTenantBranches(tenantId),
        requiresAuth: true,
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> branchesJson = jsonResponse['data'] ?? [];
        final branches = branchesJson
            .map((json) => BranchModel.fromJson(json))
            .toList();

        return ApiResponse(message: jsonResponse['message'], data: branches);
      } else {
        return ApiResponse(
          error: jsonResponse['error'] ?? 'Failed to list branches',
        );
      }
    } catch (e) {
      return ApiResponse(error: 'Error listing branches: $e');
    }
  }
}

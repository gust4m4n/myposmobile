import '../shared/api_models.dart';
import '../shared/utils/api_x.dart';

class BranchesService {
  /// Get branches by tenant ID (Superadmin only)
  static Future<ApiResponse<List<dynamic>>> getBranchesByTenant(
    int tenantId,
  ) async {
    return await ApiX.get(
      '/api/v1/superadmin/tenants/$tenantId/branches',
      requiresAuth: true,
    );
  }

  /// Get users by branch ID (Superadmin only)
  static Future<ApiResponse<List<dynamic>>> getUsersByBranch(
    int tenantId,
    int branchId,
  ) async {
    return await ApiX.get(
      '/api/v1/superadmin/tenants/$tenantId/branches/$branchId/users',
      requiresAuth: true,
    );
  }

  /// Create new branch (Superadmin only)
  static Future<ApiResponse<Map<String, dynamic>>> createBranch({
    required int tenantId,
    required String name,
    required String code,
    required String address,
    required String phone,
    required bool isActive,
  }) async {
    return await ApiX.post(
      '/api/v1/superadmin/tenants/$tenantId/branches',
      body: {
        'name': name,
        'code': code,
        'address': address,
        'phone': phone,
        'is_active': isActive,
      },
      requiresAuth: true,
    );
  }

  /// Update existing branch (Superadmin only)
  static Future<ApiResponse<Map<String, dynamic>>> updateBranch({
    required int tenantId,
    required int branchId,
    String? name,
    String? code,
    String? address,
    String? phone,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (code != null) body['code'] = code;
    if (address != null) body['address'] = address;
    if (phone != null) body['phone'] = phone;
    if (isActive != null) body['is_active'] = isActive;

    return await ApiX.put(
      '/api/v1/superadmin/tenants/$tenantId/branches/$branchId',
      body: body,
      requiresAuth: true,
    );
  }

  /// Delete branch (Superadmin only)
  static Future<ApiResponse<Map<String, dynamic>>> deleteBranch({
    required int tenantId,
    required int branchId,
  }) async {
    return await ApiX.delete(
      '/api/v1/superadmin/tenants/$tenantId/branches/$branchId',
      requiresAuth: true,
    );
  }
}

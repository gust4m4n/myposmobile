import 'dart:io';

import '../../shared/api_models.dart';
import '../../shared/utils/api_x.dart';

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
    required String description,
    required String address,
    required String website,
    required String email,
    required String phone,
    required bool isActive,
    File? imageFile,
  }) async {
    return await ApiX.postMultipart(
      '/api/v1/superadmin/branches',
      fields: {
        'tenant_id': tenantId.toString(),
        'name': name,
        'code': code,
        'description': description,
        'address': address,
        'website': website,
        'email': email,
        'phone': phone,
        'is_active': isActive.toString(),
      },
      filePath: imageFile?.path,
      fileFieldName: 'image',
      requiresAuth: true,
    );
  }

  /// Update existing branch (Superadmin only)
  static Future<ApiResponse<Map<String, dynamic>>> updateBranch({
    required int branchId,
    required String name,
    required String code,
    required String description,
    required String address,
    required String website,
    required String email,
    required String phone,
    required bool isActive,
    File? imageFile,
  }) async {
    return await ApiX.putMultipart(
      '/api/v1/superadmin/branches/$branchId',
      fields: {
        'name': name,
        'code': code,
        'description': description,
        'address': address,
        'website': website,
        'email': email,
        'phone': phone,
        'is_active': isActive.toString(),
      },
      filePath: imageFile?.path,
      fileFieldName: 'image',
      requiresAuth: true,
    );
  }

  /// Delete branch (Superadmin only)
  static Future<ApiResponse<Map<String, dynamic>>> deleteBranch({
    required int branchId,
  }) async {
    return await ApiX.delete(
      '/api/v1/superadmin/branches/$branchId',
      requiresAuth: true,
    );
  }
}

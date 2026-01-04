import 'dart:io';

import '../../shared/api_models.dart';
import '../../shared/config/api_config.dart';
import '../../shared/utils/api_x.dart';

class BranchesService {
  // ===== Tenant Admin Endpoints =====

  /// Get list of branches in user's tenant (Tenant Admin)
  /// Automatically uses tenant from JWT token
  static Future<ApiResponse<List<dynamic>>> getBranches() async {
    return await ApiX.get(ApiConfig.branches, requiresAuth: true);
  }

  /// Get branch detail by ID (Tenant Admin)
  static Future<ApiResponse<Map<String, dynamic>>> getBranchById(
    int branchId,
  ) async {
    return await ApiX.get(ApiConfig.branchById(branchId), requiresAuth: true);
  }

  /// Create new branch in user's tenant (Tenant Admin)
  static Future<ApiResponse<Map<String, dynamic>>> createBranch({
    required String name,
    String? description,
    String? address,
    String? website,
    String? email,
    String? phone,
    File? imageFile,
  }) async {
    final fields = <String, String>{
      'name': name,
      if (description != null && description.isNotEmpty)
        'description': description,
      if (address != null && address.isNotEmpty) 'address': address,
      if (website != null && website.isNotEmpty) 'website': website,
      if (email != null && email.isNotEmpty) 'email': email,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    };

    return await ApiX.postMultipart(
      ApiConfig.branches,
      fields: fields,
      filePath: imageFile?.path,
      fileFieldName: 'image',
      requiresAuth: true,
    );
  }

  /// Update branch in user's tenant (Tenant Admin)
  static Future<ApiResponse<Map<String, dynamic>>> updateBranch({
    required int branchId,
    String? name,
    String? description,
    String? address,
    String? website,
    String? email,
    String? phone,
    File? imageFile,
  }) async {
    final fields = <String, String>{
      if (name != null && name.isNotEmpty) 'name': name,
      if (description != null && description.isNotEmpty)
        'description': description,
      if (address != null && address.isNotEmpty) 'address': address,
      if (website != null && website.isNotEmpty) 'website': website,
      if (email != null && email.isNotEmpty) 'email': email,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    };

    return await ApiX.putMultipart(
      ApiConfig.branchById(branchId),
      fields: fields,
      filePath: imageFile?.path,
      fileFieldName: 'image',
      requiresAuth: true,
    );
  }

  /// Delete branch in user's tenant (Tenant Admin)
  static Future<ApiResponse<Map<String, dynamic>>> deleteBranch({
    required int branchId,
  }) async {
    return await ApiX.delete(
      ApiConfig.branchById(branchId),
      requiresAuth: true,
    );
  }

  /// Get users in a branch (Tenant Admin)
  static Future<ApiResponse<Map<String, dynamic>>> getBranchUsers(
    int branchId,
  ) async {
    return await ApiX.get(ApiConfig.branchUsers(branchId), requiresAuth: true);
  }

  // ===== Superadmin Endpoints =====

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
  static Future<ApiResponse<Map<String, dynamic>>> createBranchSuperadmin({
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
  static Future<ApiResponse<Map<String, dynamic>>> updateBranchSuperadmin({
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
  static Future<ApiResponse<Map<String, dynamic>>> deleteBranchSuperadmin({
    required int branchId,
  }) async {
    return await ApiX.delete(
      '/api/v1/superadmin/branches/$branchId',
      requiresAuth: true,
    );
  }
}

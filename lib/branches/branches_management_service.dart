import 'dart:io';

import '../shared/api_models.dart' hide BranchModel;
import '../shared/config/api_config.dart';
import '../shared/utils/api_x.dart';
import 'branch_model.dart';

class BranchesManagementService {
  /// Get list of branches for a specific tenant with optional pagination
  Future<ApiResponse<List<BranchModel>>> getBranches(
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

  /// Create new branch
  Future<ApiResponse<BranchModel>> createBranch({
    required int tenantId,
    required String name,
    required String description,
    required String address,
    required String website,
    required String email,
    required String phone,
    required bool isActive,
    File? imageFile,
  }) async {
    return await ApiX.postMultipart(
      '${ApiConfig.apiPrefix}/superadmin/branches',
      fields: {
        'tenant_id': tenantId.toString(),
        'name': name,
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
      fromJson: (data) => BranchModel.fromJson(data),
    );
  }

  /// Update existing branch
  Future<ApiResponse<BranchModel>> updateBranch({
    required int id,
    required int tenantId,
    required String name,
    required String description,
    required String address,
    required String website,
    required String email,
    required String phone,
    required bool isActive,
    File? imageFile,
  }) async {
    return await ApiX.putMultipart(
      '${ApiConfig.apiPrefix}/superadmin/branches/$id',
      fields: {
        'tenant_id': tenantId.toString(),
        'name': name,
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
      fromJson: (data) => BranchModel.fromJson(data),
    );
  }

  /// Delete branch
  Future<ApiResponse<void>> deleteBranch(int id) async {
    return await ApiX.delete(
      '${ApiConfig.apiPrefix}/superadmin/branches/$id',
      requiresAuth: true,
    );
  }
}

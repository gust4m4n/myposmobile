import 'dart:io';

import '../../shared/api_models.dart' hide BranchModel;
import '../../shared/config/api_config.dart';
import '../../shared/utils/api_x.dart';
import '../models/branch_model.dart';

class BranchesManagementService {
  /// Get list of branches for current tenant (from JWT token) with pagination
  ///
  /// Parameters:
  /// - page: Page number (default: 1)
  /// - pageSize: Items per page (default: 20)
  ///
  /// Returns:
  /// - BranchListResponse containing paginated branch data
  ///
  /// Note: Branches are automatically filtered by tenant_id from JWT token
  ///
  /// Example:
  /// ```dart
  /// final response = await service.getBranchesForCurrentTenant(page: 1, pageSize: 20);
  /// if (response.statusCode == 200 && response.data != null) {
  ///   final branchList = response.data!;
  ///   print('Total branches: ${branchList.totalItems}');
  ///   for (var branch in branchList.data) {
  ///     print(branch.name);
  ///   }
  /// }
  /// ```
  Future<ApiResponse<BranchListResponse>> getBranchesForCurrentTenant({
    int page = 1,
    int pageSize = 20,
  }) async {
    String url = '${ApiConfig.branches}?page=$page&page_size=$pageSize';

    return await ApiX.get(
      url,
      requiresAuth: true,
      fromJson: (data) {
        // Handle both List response (old format) and paginated response (new format)
        if (data is List) {
          // Old format: API returns List directly, create pagination wrapper manually
          return BranchListResponse(
            page: page,
            pageSize: pageSize,
            totalItems: data.length,
            totalPages: 1,
            data: data
                .map(
                  (json) => BranchModel.fromJson(json as Map<String, dynamic>),
                )
                .toList(),
          );
        } else if (data is Map<String, dynamic>) {
          // New format: API returns paginated response
          return BranchListResponse.fromJson(data);
        } else {
          throw Exception('Unexpected response format');
        }
      },
    );
  }

  /// Create new branch (tenant_id from JWT token)
  Future<ApiResponse<BranchModel>> createBranchForCurrentTenant({
    required String name,
    String? description,
    String? address,
    String? website,
    String? email,
    String? phone,
    bool? isActive,
    File? image,
  }) async {
    final fields = <String, String>{
      'name': name,
      if (description != null && description.isNotEmpty)
        'description': description,
      if (address != null && address.isNotEmpty) 'address': address,
      if (website != null && website.isNotEmpty) 'website': website,
      if (email != null && email.isNotEmpty) 'email': email,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (isActive != null) 'is_active': isActive.toString(),
    };

    return await ApiX.postMultipart(
      ApiConfig.branches,
      fields: fields,
      filePath: image?.path,
      requiresAuth: true,
      fromJson: (data) => BranchModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Update existing branch
  Future<ApiResponse<BranchModel>> updateBranch({
    required int branchId,
    String? name,
    String? description,
    String? address,
    String? website,
    String? email,
    String? phone,
    bool? isActive,
    File? image,
  }) async {
    final fields = <String, String>{
      if (name != null && name.isNotEmpty) 'name': name,
      if (description != null && description.isNotEmpty)
        'description': description,
      if (address != null && address.isNotEmpty) 'address': address,
      if (website != null && website.isNotEmpty) 'website': website,
      if (email != null && email.isNotEmpty) 'email': email,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (isActive != null) 'is_active': isActive.toString(),
    };

    return await ApiX.putMultipart(
      '${ApiConfig.branches}/$branchId',
      fields: fields,
      filePath: image?.path,
      requiresAuth: true,
      fromJson: (data) => BranchModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Delete branch by ID
  Future<ApiResponse<void>> deleteBranch(int branchId) async {
    return await ApiX.delete(
      '${ApiConfig.branches}/$branchId',
      requiresAuth: true,
    );
  }
}

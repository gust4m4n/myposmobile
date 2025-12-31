import 'dart:io';

import '../shared/api_models.dart' hide TenantModel;
import '../shared/config/api_config.dart';
import '../shared/utils/api_x.dart';
import 'tenant_model.dart';

class TenantsManagementService {
  /// Get list of all tenants
  Future<ApiResponse<List<TenantModel>>> getTenants() async {
    return await ApiX.get(
      ApiConfig.superadminTenants,
      requiresAuth: true,
      fromJson: (data) =>
          (data as List).map((json) => TenantModel.fromJson(json)).toList(),
    );
  }

  /// Create new tenant
  Future<ApiResponse<TenantModel>> createTenant({
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
      ApiConfig.superadminTenants,
      fields: {
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
      fromJson: (data) => TenantModel.fromJson(data),
    );
  }

  /// Update existing tenant
  Future<ApiResponse<TenantModel>> updateTenant({
    required int id,
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
      '${ApiConfig.superadminTenants}/$id',
      fields: {
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
      fromJson: (data) => TenantModel.fromJson(data),
    );
  }

  /// Delete tenant
  Future<ApiResponse<void>> deleteTenant(int id) async {
    return await ApiX.delete(
      '${ApiConfig.superadminTenants}/$id',
      requiresAuth: true,
    );
  }
}

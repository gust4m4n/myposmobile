import 'dart:io';

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
  /// Create a new tenant with optional image
  /// Requires JWT token with superadmin role
  ///
  /// Parameters:
  /// - name: Tenant name
  /// - code: Tenant code (unique)
  /// - description: Tenant description
  /// - address: Tenant address
  /// - website: Tenant website
  /// - email: Tenant email
  /// - phone: Tenant phone
  /// - isActive: Active status (default: true)
  /// - imageFile: Optional tenant logo/image (jpg, jpeg, png, gif, webp, max 5MB)
  ///
  /// Returns: Created TenantModel
  Future<ApiResponse<TenantModel>> createTenant({
    required String name,
    required String code,
    required String description,
    required String address,
    required String website,
    required String email,
    required String phone,
    bool isActive = true,
    File? imageFile,
  }) async {
    return await ApiX.postMultipart<TenantModel>(
      ApiConfig.superadminTenants,
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
      fromJson: (data) => TenantModel.fromJson(data),
    );
  }

  /// PUT /api/v1/superadmin/tenants/:id
  /// Update an existing tenant with optional image
  /// Requires JWT token with superadmin role
  ///
  /// Parameters:
  /// - tenantId: ID of tenant to update
  /// - name: Tenant name
  /// - code: Tenant code (unique)
  /// - description: Tenant description
  /// - address: Tenant address
  /// - website: Tenant website
  /// - email: Tenant email
  /// - phone: Tenant phone
  /// - isActive: Active status
  /// - imageFile: Optional tenant logo/image (old image will be deleted if new one is uploaded)
  ///
  /// Returns: Updated TenantModel
  Future<ApiResponse<TenantModel>> updateTenant({
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
    return await ApiX.putMultipart<TenantModel>(
      '${ApiConfig.superadminTenants}/$tenantId',
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
      fromJson: (data) => TenantModel.fromJson(data),
    );
  }

  /// DELETE /api/v1/superadmin/tenants/:id
  /// Delete a tenant
  /// Requires JWT token with superadmin role
  ///
  /// Parameters:
  /// - tenantId: ID of tenant to delete
  ///
  /// Returns: Success response
  Future<ApiResponse<Map<String, dynamic>>> deleteTenant({
    required int tenantId,
  }) async {
    return await ApiX.delete(
      '${ApiConfig.superadminTenants}/$tenantId',
      requiresAuth: true,
    );
  }
}

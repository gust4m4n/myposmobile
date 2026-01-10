import 'dart:io';

import '../../shared/api_models.dart';
import '../../shared/utils/api_x.dart';

class TenantsService {
  /// Get list of all tenants with pagination (Authenticated users)
  /// Returns paginated response with metadata
  static Future<ApiResponse<Map<String, dynamic>>> getTenants({
    int page = 1,
    int pageSize = 32,
  }) async {
    final url = '/tenants?page=$page&page_size=$pageSize';

    return await ApiX.get(url, requiresAuth: true);
  }

  /// Get tenant detail by ID (Authenticated users)
  static Future<ApiResponse<Map<String, dynamic>>> getTenantById(
    int tenantId,
  ) async {
    return await ApiX.get('/tenants/$tenantId', requiresAuth: true);
  }

  /// Create new tenant (Authenticated users)
  static Future<ApiResponse<Map<String, dynamic>>> createTenant({
    required String name,
    required String code,
    String? description,
    String? address,
    String? website,
    String? email,
    String? phone,
    bool? isActive,
    File? imageFile,
  }) async {
    final fields = <String, String>{
      'name': name,
      'code': code,
      if (description != null && description.isNotEmpty)
        'description': description,
      if (address != null && address.isNotEmpty) 'address': address,
      if (website != null && website.isNotEmpty) 'website': website,
      if (email != null && email.isNotEmpty) 'email': email,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (isActive != null) 'is_active': isActive.toString(),
    };

    return await ApiX.postMultipart(
      '/tenants',
      fields: fields,
      filePath: imageFile?.path,
      fileFieldName: 'image',
      requiresAuth: true,
    );
  }

  /// Update existing tenant (Authenticated users)
  /// All fields are required including code
  static Future<ApiResponse<Map<String, dynamic>>> updateTenant({
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
    final fields = <String, String>{
      'name': name,
      'code': code,
      'description': description,
      'address': address,
      'website': website,
      'email': email,
      'phone': phone,
      'is_active': isActive.toString(),
    };

    return await ApiX.putMultipart(
      '/tenants/$tenantId',
      fields: fields,
      filePath: imageFile?.path,
      fileFieldName: 'image',
      requiresAuth: true,
    );
  }

  /// Delete tenant (Authenticated users)
  /// Soft delete - tenant will be marked as deleted
  static Future<ApiResponse<Map<String, dynamic>>> deleteTenant({
    required int tenantId,
  }) async {
    return await ApiX.delete('/tenants/$tenantId', requiresAuth: true);
  }
}

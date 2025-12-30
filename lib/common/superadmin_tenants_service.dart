import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../shared/api_models.dart';
import '../shared/config/api_config.dart';
import '../shared/utils/api_x.dart';
import '../shared/utils/storage_service.dart';

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
    try {
      final storage = await StorageService.getInstance();
      final token = storage.getToken();

      if (token == null) {
        return ApiResponse<TenantModel>(
          error: 'No authentication token',
          statusCode: 401,
        );
      }

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.superadminTenants}',
      );
      final request = http.MultipartRequest('POST', uri);

      // Add auth header
      request.headers['Authorization'] = 'Bearer $token';

      // Add form fields
      request.fields['name'] = name;
      request.fields['code'] = code;
      request.fields['description'] = description;
      request.fields['address'] = address;
      request.fields['website'] = website;
      request.fields['email'] = email;
      request.fields['phone'] = phone;
      request.fields['is_active'] = isActive.toString();

      // Add image file if provided
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return ApiResponse<TenantModel>(
          data: TenantModel.fromJson(data),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<TenantModel>(
          error: response.body,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<TenantModel>(
        error: 'Failed to create tenant: $e',
        statusCode: 0,
      );
    }
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
    try {
      final storage = await StorageService.getInstance();
      final token = storage.getToken();

      if (token == null) {
        return ApiResponse<TenantModel>(
          error: 'No authentication token',
          statusCode: 401,
        );
      }

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.superadminTenants}/$tenantId',
      );
      final request = http.MultipartRequest('PUT', uri);

      // Add auth header
      request.headers['Authorization'] = 'Bearer $token';

      // Add form fields
      request.fields['name'] = name;
      request.fields['code'] = code;
      request.fields['description'] = description;
      request.fields['address'] = address;
      request.fields['website'] = website;
      request.fields['email'] = email;
      request.fields['phone'] = phone;
      request.fields['is_active'] = isActive.toString();

      // Add image file if provided
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return ApiResponse<TenantModel>(
          data: TenantModel.fromJson(data),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<TenantModel>(
          error: response.body,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<TenantModel>(
        error: 'Failed to update tenant: $e',
        statusCode: 0,
      );
    }
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

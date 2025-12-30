import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../shared/api_models.dart';
import '../shared/config/api_config.dart';
import '../shared/utils/api_x.dart';
import '../shared/utils/storage_service.dart';

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
    try {
      final storage = await StorageService.getInstance();
      final token = storage.getToken();

      if (token == null) {
        return ApiResponse<Map<String, dynamic>>(
          error: 'No authentication token',
          statusCode: 401,
        );
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/superadmin/branches');
      final request = http.MultipartRequest('POST', uri);

      // Add auth header
      request.headers['Authorization'] = 'Bearer $token';

      // Add form fields
      request.fields['tenant_id'] = tenantId.toString();
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
        return ApiResponse<Map<String, dynamic>>(
          data: data,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          error: response.body,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        error: 'Failed to create branch: $e',
        statusCode: 0,
      );
    }
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
    try {
      final storage = await StorageService.getInstance();
      final token = storage.getToken();

      if (token == null) {
        return ApiResponse<Map<String, dynamic>>(
          error: 'No authentication token',
          statusCode: 401,
        );
      }

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/v1/superadmin/branches/$branchId',
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
        return ApiResponse<Map<String, dynamic>>(
          data: data,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          error: response.body,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        error: 'Failed to update branch: $e',
        statusCode: 0,
      );
    }
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

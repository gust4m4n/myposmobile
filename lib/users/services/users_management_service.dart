import 'dart:io';

import '../../shared/api_models.dart';
import '../../shared/utils/api_x.dart';

class UsersManagementService {
  /// Get all users for tenant with optional pagination
  static Future<ApiResponse<dynamic>> getUsers({
    int? page,
    int? pageSize,
  }) async {
    String url = '/api/v1/users';
    final queryParams = <String>[];

    if (page != null) queryParams.add('page=$page');
    if (pageSize != null) queryParams.add('page_size=$pageSize');

    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    return await ApiX.get(url, requiresAuth: true);
  }

  /// Get user by ID
  static Future<ApiResponse<Map<String, dynamic>>> getUserById(int id) async {
    return await ApiX.get('/api/v1/users/$id', requiresAuth: true);
  }

  /// Create new user with optional image upload
  static Future<ApiResponse<Map<String, dynamic>>> createUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
    required int branchId,
    bool isActive = true,
    File? imageFile,
  }) async {
    return await ApiX.postMultipart(
      '/api/v1/users',
      fields: {
        'email': email,
        'password': password,
        'full_name': fullName,
        'role': role,
        'branch_id': branchId.toString(),
        'is_active': isActive.toString(),
      },
      filePath: imageFile?.path,
      fileFieldName: 'image',
      requiresAuth: true,
    );
  }

  /// Update existing user with optional image upload
  static Future<ApiResponse<Map<String, dynamic>>> updateUser({
    required int id,
    String? email,
    String? password,
    String? fullName,
    String? role,
    int? branchId,
    bool? isActive,
    File? imageFile,
  }) async {
    final fields = <String, String>{};
    if (email != null) fields['email'] = email;
    if (password != null) fields['password'] = password;
    if (fullName != null) fields['full_name'] = fullName;
    if (role != null) fields['role'] = role;
    if (branchId != null) fields['branch_id'] = branchId.toString();
    if (isActive != null) fields['is_active'] = isActive.toString();

    return await ApiX.putMultipart(
      '/api/v1/users/$id',
      fields: fields,
      filePath: imageFile?.path,
      fileFieldName: 'image',
      requiresAuth: true,
    );
  }

  /// Delete user (soft delete)
  static Future<ApiResponse<Map<String, dynamic>>> deleteUser(int id) async {
    return await ApiX.delete('/api/v1/users/$id', requiresAuth: true);
  }
}

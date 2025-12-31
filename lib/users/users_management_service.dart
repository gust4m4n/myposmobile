import 'dart:io';

import '../shared/api_models.dart';
import '../shared/utils/api_x.dart';

class UsersManagementService {
  /// Get all users for tenant
  static Future<ApiResponse<dynamic>> getUsers() async {
    return await ApiX.get('/api/v1/users', requiresAuth: true);
  }

  /// Get user by ID
  static Future<ApiResponse<Map<String, dynamic>>> getUserById(int id) async {
    return await ApiX.get('/api/v1/users/$id', requiresAuth: true);
  }

  /// Create new user
  static Future<ApiResponse<Map<String, dynamic>>> createUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
    required int branchId,
    bool isActive = true,
    File? imageFile,
  }) async {
    // If image is provided, use multipart
    if (imageFile != null) {
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
        filePath: imageFile.path,
        fileFieldName: 'image',
        requiresAuth: true,
      );
    }

    // Otherwise use JSON
    return await ApiX.post(
      '/api/v1/users',
      requiresAuth: true,
      body: {
        'email': email,
        'password': password,
        'full_name': fullName,
        'role': role,
        'branch_id': branchId,
        'is_active': isActive,
      },
    );
  }

  /// Update existing user
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
    // If image is provided, use multipart
    if (imageFile != null) {
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
        filePath: imageFile.path,
        fileFieldName: 'image',
        requiresAuth: true,
      );
    }

    // Otherwise use JSON
    final body = <String, dynamic>{};
    if (email != null) body['email'] = email;
    if (password != null) body['password'] = password;
    if (fullName != null) body['full_name'] = fullName;
    if (role != null) body['role'] = role;
    if (branchId != null) body['branch_id'] = branchId;
    if (isActive != null) body['is_active'] = isActive;

    return await ApiX.put('/api/v1/users/$id', requiresAuth: true, body: body);
  }

  /// Delete user (soft delete)
  static Future<ApiResponse<Map<String, dynamic>>> deleteUser(int id) async {
    return await ApiX.delete('/api/v1/users/$id', requiresAuth: true);
  }
}

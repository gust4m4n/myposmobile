import 'dart:io';

import '../../shared/api_models.dart';
import '../../shared/utils/api_x.dart';
import '../models/user_management_model.dart';
import 'user_offline_service.dart';

class UsersManagementService {
  static final UserOfflineService _offlineService = UserOfflineService();

  /// Get all users for tenant with optional pagination
  static Future<ApiResponse<PaginatedResponse<UserManagementModel>>> getUsers({
    int? page,
    int? pageSize,
  }) async {
    String url = '/users';
    final queryParams = <String>[];

    if (page != null) queryParams.add('page=$page');
    if (pageSize != null) queryParams.add('page_size=$pageSize');

    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    // Get raw response without fromJson transformation
    final response = await ApiX.get<dynamic>(url, requiresAuth: true);

    // Manually transform response to PaginatedResponse
    if (response.data != null && response.data is Map) {
      final jsonData = response.data as Map<String, dynamic>;
      final paginatedData = PaginatedResponse<UserManagementModel>(
        page: jsonData['page'] ?? 1,
        pageSize: jsonData['page_size'] ?? 20,
        totalItems: jsonData['total_items'] ?? 0,
        totalPages: jsonData['total_pages'] ?? 1,
        data:
            (jsonData['data'] as List<dynamic>?)
                ?.map(
                  (item) => UserManagementModel.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList() ??
            [],
      );

      return ApiResponse<PaginatedResponse<UserManagementModel>>(
        code: response.code,
        message: response.message,
        data: paginatedData,
        error: response.error,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse<PaginatedResponse<UserManagementModel>>(
      code: response.code,
      message: response.message,
      data: null,
      error: response.error,
      statusCode: response.statusCode,
    );
  }

  /// Get user by ID
  static Future<ApiResponse<Map<String, dynamic>>> getUserById(int id) async {
    return await ApiX.get('/users/$id', requiresAuth: true);
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
      '/users',
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
      '/users/$id',
      fields: fields,
      filePath: imageFile?.path,
      fileFieldName: 'image',
      requiresAuth: true,
    );
  }

  /// Delete user (soft delete)
  static Future<ApiResponse<Map<String, dynamic>>> deleteUser(int id) async {
    return await ApiX.delete('/users/$id', requiresAuth: true);
  }

  /// Sync users from server to local DB
  static Future<void> syncUsersFromServer() async {
    try {
      final response = await getUsers(page: 1, pageSize: 999999);
      if (response.statusCode == 200 && response.data != null) {
        final users = response.data!.data;
        await _offlineService.saveUsers(users);
      }
    } catch (e) {
      print('Error syncing users: $e');
      rethrow;
    }
  }

  /// Get users from local DB
  static Future<List<UserManagementModel>> getUsersFromLocal() async {
    return await _offlineService.getAllUsers();
  }

  /// Get active users from local DB
  static Future<List<UserManagementModel>> getActiveUsersFromLocal() async {
    return await _offlineService.getActiveUsers();
  }

  /// Get users by branch ID from local DB
  static Future<List<UserManagementModel>> getUsersByBranchIdFromLocal(
    int branchId,
  ) async {
    return await _offlineService.getUsersByBranchId(branchId);
  }

  /// Get user by email from local DB (for offline login)
  static Future<UserManagementModel?> getUserByEmailFromLocal(
    String email,
  ) async {
    return await _offlineService.getUserByEmail(email);
  }
}

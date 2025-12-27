import '../shared/api_models.dart';
import '../shared/utils/api_x.dart';

class UsersService {
  /// Get all users for tenant
  static Future<ApiResponse<List<dynamic>>> getUsers() async {
    return await ApiX.get('/users');
  }

  /// Get user by ID
  static Future<ApiResponse<Map<String, dynamic>>> getUserById(int id) async {
    return await ApiX.get('/users/$id');
  }

  /// Create new user
  static Future<ApiResponse<Map<String, dynamic>>> createUser({
    required String username,
    required String email,
    required String password,
    required String fullName,
    required String role,
    required int branchId,
    required bool isActive,
  }) async {
    return await ApiX.post(
      '/users',
      body: {
        'username': username,
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
    String? username,
    String? email,
    String? password,
    String? fullName,
    String? role,
    int? branchId,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (email != null) body['email'] = email;
    if (password != null) body['password'] = password;
    if (fullName != null) body['full_name'] = fullName;
    if (role != null) body['role'] = role;
    if (branchId != null) body['branch_id'] = branchId;
    if (isActive != null) body['is_active'] = isActive;

    return await ApiX.put('/users/$id', body: body);
  }

  /// Delete user (soft delete)
  static Future<ApiResponse<Map<String, dynamic>>> deleteUser(int id) async {
    return await ApiX.delete('/users/$id');
  }
}

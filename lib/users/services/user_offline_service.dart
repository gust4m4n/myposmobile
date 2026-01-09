import 'package:sqflite/sqflite.dart';

import '../../shared/database/database_helper.dart';
import '../models/user_management_model.dart';

class UserOfflineService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Save single user to local DB
  Future<int> saveUser(UserManagementModel user) async {
    final db = await _dbHelper.database;

    final data = {
      'id': user.id,
      if (user.remoteId != null) 'remote_id': user.remoteId,
      'tenant_id': user.tenantId,
      'branch_id': user.branchId,
      'email': user.email,
      'password': user.password, // Store securely
      'pin': user.pin, // Store securely
      'full_name': user.fullName,
      'phone': user.phone,
      'role': user.role,
      'image': user.image,
      'is_active': user.isActive == true ? 1 : 0,
      'created_at': user.createdAt,
      'updated_at': user.updatedAt,
      'created_by': user.createdBy,
      'created_by_name': user.createdByName,
      'updated_by': user.updatedBy,
      'updated_by_name': user.updatedByName,
      'synced': 1,
      'last_synced_at': DateTime.now().toUtc().toIso8601String(),
    };

    return await db.insert(
      'users',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Save multiple users (bulk insert for sync)
  Future<void> saveUsers(List<UserManagementModel> users) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (var user in users) {
      final data = {
        'id': user.id,
        'tenant_id': user.tenantId,
        'branch_id': user.branchId,
        'email': user.email,
        'password': user.password,
        'pin': user.pin,
        'name': user.fullName, // For backwards compatibility with old schema
        'full_name': user.fullName,
        'phone': user.phone,
        'role': user.role,
        'image': user.image,
        'is_active': user.isActive == true ? 1 : 0,
        'created_at': user.createdAt,
        'updated_at': user.updatedAt,
        'created_by': user.createdBy,
        'created_by_name': user.createdByName,
        'updated_by': user.updatedBy,
        'updated_by_name': user.updatedByName,
        'synced': 1,
        'last_synced_at': DateTime.now().toUtc().toIso8601String(),
      };

      batch.insert('users', data, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  /// Get all users from local DB
  Future<List<UserManagementModel>> getAllUsers() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      orderBy: 'full_name ASC',
    );

    return maps.map((map) => _mapToUser(map)).toList();
  }

  /// Get active users only
  Future<List<UserManagementModel>> getActiveUsers() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'full_name ASC',
    );

    return maps.map((map) => _mapToUser(map)).toList();
  }

  /// Get users by branch ID
  Future<List<UserManagementModel>> getUsersByBranchId(int branchId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'branch_id = ?',
      whereArgs: [branchId],
      orderBy: 'full_name ASC',
    );

    return maps.map((map) => _mapToUser(map)).toList();
  }

  /// Get users by role
  Future<List<UserManagementModel>> getUsersByRole(String role) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: [role],
      orderBy: 'full_name ASC',
    );

    return maps.map((map) => _mapToUser(map)).toList();
  }

  /// Get user by local ID
  Future<UserManagementModel?> getUserById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _mapToUser(maps.first);
  }

  /// Get user by remote ID (from server)
  Future<UserManagementModel?> getUserByRemoteId(int remoteId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'remote_id = ?',
      whereArgs: [remoteId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _mapToUser(maps.first);
  }

  /// Get user by email (for login)
  Future<UserManagementModel?> getUserByEmail(String email) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _mapToUser(maps.first);
  }

  /// Update user in local DB
  Future<int> updateUser(UserManagementModel user) async {
    final db = await _dbHelper.database;

    final data = {
      if (user.remoteId != null) 'remote_id': user.remoteId,
      'tenant_id': user.tenantId,
      'branch_id': user.branchId,
      'email': user.email,
      if (user.password != null) 'password': user.password,
      if (user.pin != null) 'pin': user.pin,
      'full_name': user.fullName,
      'phone': user.phone,
      'role': user.role,
      'image': user.image,
      'is_active': user.isActive == true ? 1 : 0,
      'updated_at': user.updatedAt ?? DateTime.now().toUtc().toIso8601String(),
      'updated_by': user.updatedBy,
      'updated_by_name': user.updatedByName,
      'last_synced_at': DateTime.now().toUtc().toIso8601String(),
    };

    return await db.update(
      'users',
      data,
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  /// Delete user from local DB
  Future<int> deleteUser(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  /// Clear all users (for full resync)
  Future<void> clearAllUsers() async {
    final db = await _dbHelper.database;
    await db.delete('users');
  }

  /// Count total users
  Future<int> getUserCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Map database row to UserManagementModel
  UserManagementModel _mapToUser(Map<String, dynamic> map) {
    return UserManagementModel(
      id: map['id'] as int? ?? 0,
      remoteId: map['remote_id'] as int?,
      tenantId: map['tenant_id'] as int? ?? 0,
      branchId: map['branch_id'] as int? ?? 0,
      email: map['email'] as String,
      password: map['password'] as String?,
      pin: map['pin'] as String?,
      fullName: map['full_name'] as String,
      phone: map['phone'] as String?,
      role: map['role'] as String? ?? '',
      image: map['image'] as String?,
      isActive: map['is_active'] == 1,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
      createdBy: map['created_by'] as int?,
      createdByName: map['created_by_name'] as String?,
      updatedBy: map['updated_by'] as int?,
      updatedByName: map['updated_by_name'] as String?,
    );
  }
}

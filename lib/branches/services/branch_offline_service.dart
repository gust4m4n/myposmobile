import 'package:sqflite/sqflite.dart';

import '../../shared/database/database_helper.dart';
import '../models/branch_model.dart';

class BranchOfflineService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Save single branch to local DB
  Future<int> saveBranch(BranchModel branch) async {
    final db = await _dbHelper.database;

    final data = {
      if (branch.id != null) 'id': branch.id,
      if (branch.remoteId != null) 'remote_id': branch.remoteId,
      'tenant_id': branch.tenantId,
      'name': branch.name,
      'code': branch.code,
      'address': branch.address,
      'city': null, // Add city field if needed
      'province': null, // Add province field if needed
      'postal_code': null, // Add postal_code field if needed
      'phone': branch.phone,
      'email': branch.email,
      'is_active': branch.isActive == true ? 1 : 0,
      'created_at': branch.createdAt,
      'updated_at': branch.updatedAt,
      'created_by': branch.createdBy,
      'created_by_name': branch.createdByName,
      'updated_by': branch.updatedBy,
      'updated_by_name': branch.updatedByName,
      'synced': 1,
      'last_synced_at': DateTime.now().toUtc().toIso8601String(),
    };

    return await db.insert(
      'branches',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Save multiple branches (bulk insert for sync)
  Future<void> saveBranches(List<BranchModel> branches) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (var branch in branches) {
      final data = {
        if (branch.id != null) 'id': branch.id,
        'tenant_id': branch.tenantId,
        'name': branch.name,
        'code': branch.code,
        'address': branch.address,
        'city': null,
        'province': null,
        'postal_code': null,
        'phone': branch.phone,
        'email': branch.email,
        'is_active': branch.isActive == true ? 1 : 0,
        'created_at': branch.createdAt,
        'updated_at': branch.updatedAt,
        'created_by': branch.createdBy,
        'created_by_name': branch.createdByName,
        'updated_by': branch.updatedBy,
        'updated_by_name': branch.updatedByName,
        'synced': 1,
        'last_synced_at': DateTime.now().toUtc().toIso8601String(),
      };

      batch.insert(
        'branches',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Get all branches from local DB
  Future<List<BranchModel>> getAllBranches() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'branches',
      orderBy: 'name ASC',
    );

    return maps.map((map) => _mapToBranch(map)).toList();
  }

  /// Get active branches only
  Future<List<BranchModel>> getActiveBranches() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'branches',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );

    return maps.map((map) => _mapToBranch(map)).toList();
  }

  /// Get branches by tenant ID
  Future<List<BranchModel>> getBranchesByTenantId(int tenantId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'branches',
      where: 'tenant_id = ?',
      whereArgs: [tenantId],
      orderBy: 'name ASC',
    );

    return maps.map((map) => _mapToBranch(map)).toList();
  }

  /// Get branch by local ID
  Future<BranchModel?> getBranchById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'branches',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _mapToBranch(maps.first);
  }

  /// Get branch by remote ID (from server)
  Future<BranchModel?> getBranchByRemoteId(int remoteId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'branches',
      where: 'remote_id = ?',
      whereArgs: [remoteId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _mapToBranch(maps.first);
  }

  /// Update branch in local DB
  Future<int> updateBranch(BranchModel branch) async {
    final db = await _dbHelper.database;

    final data = {
      if (branch.remoteId != null) 'remote_id': branch.remoteId,
      'tenant_id': branch.tenantId,
      'name': branch.name,
      'code': branch.code,
      'address': branch.address,
      'phone': branch.phone,
      'email': branch.email,
      'is_active': branch.isActive == true ? 1 : 0,
      'updated_at':
          branch.updatedAt ?? DateTime.now().toUtc().toIso8601String(),
      'updated_by': branch.updatedBy,
      'updated_by_name': branch.updatedByName,
      'last_synced_at': DateTime.now().toUtc().toIso8601String(),
    };

    return await db.update(
      'branches',
      data,
      where: 'id = ?',
      whereArgs: [branch.id],
    );
  }

  /// Delete branch from local DB
  Future<int> deleteBranch(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('branches', where: 'id = ?', whereArgs: [id]);
  }

  /// Clear all branches (for full resync)
  Future<void> clearAllBranches() async {
    final db = await _dbHelper.database;
    await db.delete('branches');
  }

  /// Count total branches
  Future<int> getBranchCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM branches');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Map database row to BranchModel
  BranchModel _mapToBranch(Map<String, dynamic> map) {
    return BranchModel(
      id: map['id'] as int?,
      remoteId: map['remote_id'] as int?,
      tenantId: map['tenant_id'] as int,
      name: map['name'] as String,
      code: map['code'] as String?,
      description: null, // Not stored in DB schema, can be added if needed
      address: map['address'] as String?,
      website: null, // Not stored in DB schema
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      image: null, // Not stored in DB schema
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

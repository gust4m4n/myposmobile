import 'package:sqflite/sqflite.dart';

import '../../shared/database/database_helper.dart';
import '../models/tenant_model.dart';

class TenantOfflineService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Save single tenant to local DB
  Future<int> saveTenant(TenantModel tenant) async {
    final db = await _dbHelper.database;

    final data = {
      if (tenant.id != null) 'id': tenant.id,
      if (tenant.remoteId != null) 'remote_id': tenant.remoteId,
      'name': tenant.name,
      'email': tenant.email,
      'phone': tenant.phone,
      'address': tenant.address,
      'city': null, // Will be added to model later
      'province': null, // Will be added to model later
      'postal_code': null, // Will be added to model later
      'logo': tenant.image,
      'is_active': tenant.isActive == true ? 1 : 0,
      'created_at': tenant.createdAt,
      'updated_at': tenant.updatedAt,
      'synced': 1,
      'last_synced_at': DateTime.now().toUtc().toIso8601String(),
    };

    return await db.insert(
      'tenants',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Save multiple tenants (bulk insert for sync)
  Future<void> saveTenants(List<TenantModel> tenants) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (var tenant in tenants) {
      final data = {
        if (tenant.id != null) 'id': tenant.id,
        'name': tenant.name,
        'email': tenant.email,
        'phone': tenant.phone,
        'address': tenant.address,
        'city': null,
        'province': null,
        'postal_code': null,
        'logo': tenant.image,
        'is_active': tenant.isActive == true ? 1 : 0,
        'created_at': tenant.createdAt,
        'updated_at': tenant.updatedAt,
        'synced': 1,
        'last_synced_at': DateTime.now().toUtc().toIso8601String(),
      };

      batch.insert(
        'tenants',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Get all tenants from local DB
  Future<List<TenantModel>> getAllTenants() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tenants',
      orderBy: 'name ASC',
    );

    return maps.map((map) => _mapToTenant(map)).toList();
  }

  /// Get active tenants only
  Future<List<TenantModel>> getActiveTenants() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tenants',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );

    return maps.map((map) => _mapToTenant(map)).toList();
  }

  /// Get tenant by local ID
  Future<TenantModel?> getTenantById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tenants',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _mapToTenant(maps.first);
  }

  /// Get tenant by remote ID (from server)
  Future<TenantModel?> getTenantByRemoteId(int remoteId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tenants',
      where: 'remote_id = ?',
      whereArgs: [remoteId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _mapToTenant(maps.first);
  }

  /// Update tenant in local DB
  Future<int> updateTenant(TenantModel tenant) async {
    final db = await _dbHelper.database;

    final data = {
      if (tenant.remoteId != null) 'remote_id': tenant.remoteId,
      'name': tenant.name,
      'email': tenant.email,
      'phone': tenant.phone,
      'address': tenant.address,
      'city': null,
      'province': null,
      'postal_code': null,
      'logo': tenant.image,
      'is_active': tenant.isActive == true ? 1 : 0,
      'updated_at':
          tenant.updatedAt ?? DateTime.now().toUtc().toIso8601String(),
      'last_synced_at': DateTime.now().toUtc().toIso8601String(),
    };

    return await db.update(
      'tenants',
      data,
      where: 'id = ?',
      whereArgs: [tenant.id],
    );
  }

  /// Delete tenant from local DB
  Future<int> deleteTenant(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('tenants', where: 'id = ?', whereArgs: [id]);
  }

  /// Clear all tenants (for full resync)
  Future<void> clearAllTenants() async {
    final db = await _dbHelper.database;
    await db.delete('tenants');
  }

  /// Count total tenants
  Future<int> getTenantCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM tenants');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Map database row to TenantModel
  TenantModel _mapToTenant(Map<String, dynamic> map) {
    return TenantModel(
      id: map['id'] as int?,
      remoteId: map['remote_id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      image: map['logo'] as String?,
      isActive: map['is_active'] == 1,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }
}

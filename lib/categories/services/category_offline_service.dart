import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../categories/models/category_model.dart';
import '../../shared/database/database_helper.dart';

class CategoryOfflineService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Save category ke database offline
  Future<int> saveCategory(CategoryModel category) async {
    final db = await _dbHelper.database;

    final data = {
      if (category.id != null) 'id': category.id,
      'tenant_id': category.tenantId,
      'name': category.name,
      'description': category.description,
      'image': category.image,
      'is_active': category.isActive == true ? 1 : 0,
      'created_at': category.createdAt,
      'updated_at': category.updatedAt,
      'created_by': category.createdBy,
      'created_by_name': category.createdByName,
      'updated_by': category.updatedBy,
      'updated_by_name': category.updatedByName,
      'synced': 1,
      'last_synced_at': DateTime.now().toIso8601String(),
    };

    return await db.insert(
      'categories',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Save multiple categories
  Future<void> saveCategories(List<CategoryModel> categories) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (var category in categories) {
      final data = {
        if (category.id != null) 'id': category.id,
        'tenant_id': category.tenantId,
        'name': category.name,
        'description': category.description,
        'image': category.image,
        'is_active': category.isActive == true ? 1 : 0,
        'created_at': category.createdAt,
        'updated_at': category.updatedAt,
        'created_by': category.createdBy,
        'created_by_name': category.createdByName,
        'updated_by': category.updatedBy,
        'updated_by_name': category.updatedByName,
        'synced': 1,
        'last_synced_at': DateTime.now().toIso8601String(),
      };

      batch.insert(
        'categories',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  // Get all categories
  Future<List<CategoryModel>> getAllCategories() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      orderBy: 'name ASC',
    );

    return maps.map((map) => _mapToCategory(map)).toList();
  }

  // Get active categories only
  Future<List<CategoryModel>> getActiveCategories() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );

    return maps.map((map) => _mapToCategory(map)).toList();
  }

  // Get category by ID
  Future<CategoryModel?> getCategoryById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _mapToCategory(maps.first);
  }

  // Search categories
  Future<List<CategoryModel>> searchCategories(String query) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );

    return maps.map((map) => _mapToCategory(map)).toList();
  }

  // Update category
  Future<int> updateCategory(CategoryModel category) async {
    if (category.id == null) {
      throw Exception('Category ID is required for update');
    }

    final db = await _dbHelper.database;
    final data = {
      'tenant_id': category.tenantId,
      'name': category.name,
      'description': category.description,
      'image': category.image,
      'is_active': category.isActive == true ? 1 : 0,
      'updated_at': DateTime.now().toIso8601String(),
      'synced': 0, // Mark as not synced
    };

    // Add to sync queue
    await _addToSyncQueue(category.id!, 'UPDATE', data);

    return await db.update(
      'categories',
      data,
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  // Delete category
  Future<int> deleteCategory(int id) async {
    final db = await _dbHelper.database;

    // Add to sync queue
    await _addToSyncQueue(id, 'DELETE', null);

    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // Get unsynced categories
  Future<List<CategoryModel>> getUnsyncedCategories() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'synced = ?',
      whereArgs: [0],
    );

    return maps.map((map) => _mapToCategory(map)).toList();
  }

  // Mark category as synced
  Future<void> markAsSynced(int id) async {
    final db = await _dbHelper.database;
    await db.update(
      'categories',
      {'synced': 1, 'last_synced_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Clear all categories
  Future<void> clearAllCategories() async {
    final db = await _dbHelper.database;
    await db.delete('categories');
  }

  // Helper: Convert map to CategoryModel
  CategoryModel _mapToCategory(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      tenantId: map['tenant_id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
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

  // Helper: Add to sync queue
  Future<void> _addToSyncQueue(
    int recordId,
    String operation,
    Map<String, dynamic>? data,
  ) async {
    final db = await _dbHelper.database;
    await db.insert('sync_queue', {
      'table_name': 'categories',
      'record_id': recordId,
      'operation': operation,
      'data': data != null ? jsonEncode(data) : null,
      'created_at': DateTime.now().toIso8601String(),
      'retry_count': 0,
    });
  }
}

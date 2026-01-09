import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../home/models/product_model.dart';
import '../../shared/database/database_helper.dart';

class ProductOfflineService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Save product ke database offline
  Future<int> saveProduct(ProductModel product) async {
    final db = await _dbHelper.database;

    final data = {
      if (product.id != null) 'id': product.id,
      'name': product.name,
      'price': product.price,
      'category_id': product.categoryId,
      'description': product.description,
      'sku': product.sku,
      'stock': product.stock,
      'is_active': product.isActive == true ? 1 : 0,
      'image': product.image,
      'category_detail': product.categoryDetail != null
          ? jsonEncode(product.categoryDetail)
          : null,
      'synced': 1,
      'last_synced_at': DateTime.now().toUtc().toIso8601String(),
    };

    return await db.insert(
      'products',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Save multiple products
  Future<void> saveProducts(List<ProductModel> products) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (var product in products) {
      final data = {
        if (product.id != null) 'id': product.id,
        'name': product.name,
        'price': product.price,
        'category_id': product.categoryId,
        'description': product.description,
        'sku': product.sku,
        'stock': product.stock,
        'is_active': product.isActive == true ? 1 : 0,
        'image': product.image,
        'category_detail': product.categoryDetail != null
            ? jsonEncode(product.categoryDetail)
            : null,
        'synced': 1,
        'last_synced_at': DateTime.now().toUtc().toIso8601String(),
      };

      batch.insert(
        'products',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  // Get all products
  Future<List<ProductModel>> getAllProducts() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      orderBy: 'name ASC',
    );

    return maps.map((map) => _mapToProduct(map)).toList();
  }

  // Get active products only
  Future<List<ProductModel>> getActiveProducts() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );

    return maps.map((map) => _mapToProduct(map)).toList();
  }

  // Get products by category
  Future<List<ProductModel>> getProductsByCategory(int categoryId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'category_id = ? AND is_active = ?',
      whereArgs: [categoryId, 1],
      orderBy: 'name ASC',
    );

    return maps.map((map) => _mapToProduct(map)).toList();
  }

  // Get product by ID
  Future<ProductModel?> getProductById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _mapToProduct(maps.first);
  }

  // Search products
  Future<List<ProductModel>> searchProducts(String query) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'name LIKE ? OR sku LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );

    return maps.map((map) => _mapToProduct(map)).toList();
  }

  // Get low stock products
  Future<List<ProductModel>> getLowStockProducts(int threshold) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'stock <= ? AND is_active = ?',
      whereArgs: [threshold, 1],
      orderBy: 'stock ASC',
    );

    return maps.map((map) => _mapToProduct(map)).toList();
  }

  // Update product
  Future<int> updateProduct(ProductModel product) async {
    if (product.id == null) {
      throw Exception('Product ID is required for update');
    }

    final db = await _dbHelper.database;
    final data = {
      'name': product.name,
      'price': product.price,
      'category_id': product.categoryId,
      'description': product.description,
      'sku': product.sku,
      'stock': product.stock,
      'is_active': product.isActive == true ? 1 : 0,
      'image': product.image,
      'category_detail': product.categoryDetail != null
          ? jsonEncode(product.categoryDetail)
          : null,
      'synced': 0, // Mark as not synced
    };

    // Add to sync queue
    await _addToSyncQueue(product.id!, 'UPDATE', data);

    return await db.update(
      'products',
      data,
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // Update stock
  Future<int> updateStock(int productId, int newStock) async {
    final db = await _dbHelper.database;
    final data = {'stock': newStock, 'synced': 0};

    await _addToSyncQueue(productId, 'UPDATE_STOCK', data);

    return await db.update(
      'products',
      data,
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  // Decrease stock (untuk transaksi)
  Future<bool> decreaseStock(int productId, int quantity) async {
    // Get current stock
    final product = await getProductById(productId);
    if (product == null || product.stock == null) {
      return false;
    }

    final newStock = product.stock! - quantity;
    if (newStock < 0) {
      return false; // Insufficient stock
    }

    await updateStock(productId, newStock);
    return true;
  }

  // Delete product
  Future<int> deleteProduct(int id) async {
    final db = await _dbHelper.database;

    // Add to sync queue
    await _addToSyncQueue(id, 'DELETE', null);

    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // Get unsynced products
  Future<List<ProductModel>> getUnsyncedProducts() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'synced = ?',
      whereArgs: [0],
    );

    return maps.map((map) => _mapToProduct(map)).toList();
  }

  // Mark product as synced
  Future<void> markAsSynced(int id) async {
    final db = await _dbHelper.database;
    await db.update(
      'products',
      {'synced': 1, 'last_synced_at': DateTime.now().toUtc().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Clear all products
  Future<void> clearAllProducts() async {
    final db = await _dbHelper.database;
    await db.delete('products');
  }

  // Get products count
  Future<int> getProductsCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM products');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get products by multiple categories
  Future<List<ProductModel>> getProductsByCategories(
    List<int> categoryIds,
  ) async {
    final db = await _dbHelper.database;
    final placeholders = List.filled(categoryIds.length, '?').join(',');

    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'category_id IN ($placeholders) AND is_active = ?',
      whereArgs: [...categoryIds, 1],
      orderBy: 'name ASC',
    );

    return maps.map((map) => _mapToProduct(map)).toList();
  }

  // Helper: Convert map to ProductModel
  ProductModel _mapToProduct(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      categoryId: map['category_id'] as int?,
      description: map['description'] as String?,
      sku: map['sku'] as String?,
      stock: map['stock'] as int?,
      isActive: map['is_active'] == 1,
      image: map['image'] as String?,
      categoryDetail: map['category_detail'] != null
          ? jsonDecode(map['category_detail'] as String) as Map<String, dynamic>
          : null,
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
      'table_name': 'products',
      'record_id': recordId,
      'operation': operation,
      'data': data != null ? jsonEncode(data) : null,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'retry_count': 0,
    });
  }
}

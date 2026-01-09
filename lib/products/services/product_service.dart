import 'package:get/get.dart';

import '../../home/models/product_model.dart';
import '../../shared/services/sync_integration_service.dart';
import '../../shared/utils/logger_x.dart';
import 'product_offline_service.dart';

/// Main Product Service with offline-first approach and auto-sync
/// All operations go to local DB first, then sync to server when online
class ProductService {
  final ProductOfflineService _offlineService = ProductOfflineService();
  final SyncIntegrationService _syncService =
      Get.find<SyncIntegrationService>();

  // ==================== READ OPERATIONS ====================

  /// Get all products from local DB
  Future<List<ProductModel>> getAllProducts() async {
    return await _offlineService.getAllProducts();
  }

  /// Get active products only
  Future<List<ProductModel>> getActiveProducts() async {
    return await _offlineService.getActiveProducts();
  }

  /// Get products by category
  Future<List<ProductModel>> getProductsByCategory(int categoryId) async {
    return await _offlineService.getProductsByCategory(categoryId);
  }

  /// Get products by multiple categories
  Future<List<ProductModel>> getProductsByCategories(
    List<int> categoryIds,
  ) async {
    return await _offlineService.getProductsByCategories(categoryIds);
  }

  /// Get product by ID
  Future<ProductModel?> getProductById(int id) async {
    return await _offlineService.getProductById(id);
  }

  /// Search products
  Future<List<ProductModel>> searchProducts(String query) async {
    return await _offlineService.searchProducts(query);
  }

  /// Get low stock products
  Future<List<ProductModel>> getLowStockProducts(int threshold) async {
    return await _offlineService.getLowStockProducts(threshold);
  }

  /// Get products count
  Future<int> getProductsCount() async {
    return await _offlineService.getProductsCount();
  }

  // ==================== WRITE OPERATIONS WITH AUTO-SYNC ====================

  /// Save product to local DB and auto-sync
  Future<int> saveProduct(ProductModel product) async {
    try {
      // Save to local DB first
      final id = await _offlineService.saveProduct(product);

      // Try auto-sync in background (don't wait)
      _triggerAutoSync();

      return id;
    } catch (e) {
      LoggerX.log('❌ Error saving product: $e');
      rethrow;
    }
  }

  /// Update product in local DB and auto-sync
  Future<int> updateProduct(ProductModel product) async {
    try {
      // Update in local DB first
      final result = await _offlineService.updateProduct(product);

      // Try auto-sync in background
      _triggerAutoSync();

      return result;
    } catch (e) {
      LoggerX.log('❌ Error updating product: $e');
      rethrow;
    }
  }

  /// Delete product from local DB and auto-sync
  Future<int> deleteProduct(int id) async {
    try {
      // Delete from local DB first
      final result = await _offlineService.deleteProduct(id);

      // Try auto-sync in background
      _triggerAutoSync();

      return result;
    } catch (e) {
      LoggerX.log('❌ Error deleting product: $e');
      rethrow;
    }
  }

  /// Update stock and auto-sync
  Future<int> updateStock(int productId, int newStock) async {
    try {
      // Update stock in local DB first
      final result = await _offlineService.updateStock(productId, newStock);

      // Try auto-sync in background
      _triggerAutoSync();

      return result;
    } catch (e) {
      LoggerX.log('❌ Error updating stock: $e');
      rethrow;
    }
  }

  /// Decrease stock (for transactions) and auto-sync
  Future<bool> decreaseStock(int productId, int quantity) async {
    try {
      // Decrease stock in local DB first
      final success = await _offlineService.decreaseStock(productId, quantity);

      if (success) {
        // Try auto-sync in background
        _triggerAutoSync();
      }

      return success;
    } catch (e) {
      LoggerX.log('❌ Error decreasing stock: $e');
      rethrow;
    }
  }

  // ==================== SYNC OPERATIONS ====================

  /// Trigger background sync (non-blocking)
  void _triggerAutoSync() {
    // Run sync in background without blocking UI
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        LoggerX.log('🔄 Auto-syncing products...');
        await _syncService.performFullSync();
        LoggerX.log('✅ Auto-sync completed');
      } catch (e) {
        LoggerX.log('⚠️ Auto-sync failed (will retry later): $e');
        // Silent fail - sync will happen later
      }
    });
  }

  /// Manual sync - force sync now
  Future<void> syncNow() async {
    try {
      LoggerX.log('🔄 Manual sync triggered...');
      await _syncService.performFullSync();
      LoggerX.log('✅ Manual sync completed');
    } catch (e) {
      LoggerX.log('❌ Manual sync failed: $e');
      rethrow;
    }
  }

  /// Get unsynced products count
  Future<int> getUnsyncedCount() async {
    final unsynced = await _offlineService.getUnsyncedProducts();
    return unsynced.length;
  }

  /// Get unsynced products
  Future<List<ProductModel>> getUnsyncedProducts() async {
    return await _offlineService.getUnsyncedProducts();
  }

  // ==================== BULK OPERATIONS ====================

  /// Save multiple products (used by sync download)
  Future<void> saveProducts(List<ProductModel> products) async {
    await _offlineService.saveProducts(products);
  }

  /// Clear all products (dangerous - use with caution)
  Future<void> clearAllProducts() async {
    await _offlineService.clearAllProducts();
  }
}

import 'package:get/get.dart';

import '../../categories/models/category_model.dart';
import '../../shared/services/sync_integration_service.dart';
import 'category_offline_service.dart';

/// Main Category Service with offline-first approach and auto-sync
/// All operations go to local DB first, then sync to server when online
class CategoryService {
  final CategoryOfflineService _offlineService = CategoryOfflineService();
  final SyncIntegrationService _syncService =
      Get.find<SyncIntegrationService>();

  // ==================== READ OPERATIONS ====================

  /// Get all categories from local DB
  Future<List<CategoryModel>> getAllCategories() async {
    return await _offlineService.getAllCategories();
  }

  /// Get active categories only
  Future<List<CategoryModel>> getActiveCategories() async {
    return await _offlineService.getActiveCategories();
  }

  /// Get category by ID
  Future<CategoryModel?> getCategoryById(int id) async {
    return await _offlineService.getCategoryById(id);
  }

  /// Search categories
  Future<List<CategoryModel>> searchCategories(String query) async {
    return await _offlineService.searchCategories(query);
  }

  // ==================== WRITE OPERATIONS WITH AUTO-SYNC ====================

  /// Save category to local DB and auto-sync
  Future<int> saveCategory(CategoryModel category) async {
    try {
      // Save to local DB first
      final id = await _offlineService.saveCategory(category);

      // Try auto-sync in background
      _triggerAutoSync();

      return id;
    } catch (e) {
      print('❌ Error saving category: $e');
      rethrow;
    }
  }

  /// Update category in local DB and auto-sync
  Future<int> updateCategory(CategoryModel category) async {
    try {
      // Update in local DB first
      final result = await _offlineService.updateCategory(category);

      // Try auto-sync in background
      _triggerAutoSync();

      return result;
    } catch (e) {
      print('❌ Error updating category: $e');
      rethrow;
    }
  }

  /// Delete category from local DB and auto-sync
  Future<int> deleteCategory(int id) async {
    try {
      // Delete from local DB first
      final result = await _offlineService.deleteCategory(id);

      // Try auto-sync in background
      _triggerAutoSync();

      return result;
    } catch (e) {
      print('❌ Error deleting category: $e');
      rethrow;
    }
  }

  // ==================== SYNC OPERATIONS ====================

  /// Trigger background sync (non-blocking)
  void _triggerAutoSync() {
    // Run sync in background without blocking UI
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        print('🔄 Auto-syncing categories...');
        await _syncService.performFullSync();
        print('✅ Auto-sync completed');
      } catch (e) {
        print('⚠️ Auto-sync failed (will retry later): $e');
        // Silent fail - sync will happen later
      }
    });
  }

  /// Manual sync - force sync now
  Future<void> syncNow() async {
    try {
      print('🔄 Manual sync triggered...');
      await _syncService.performFullSync();
      print('✅ Manual sync completed');
    } catch (e) {
      print('❌ Manual sync failed: $e');
      rethrow;
    }
  }

  /// Get unsynced categories count
  Future<int> getUnsyncedCount() async {
    final unsynced = await _offlineService.getUnsyncedCategories();
    return unsynced.length;
  }

  /// Get unsynced categories
  Future<List<CategoryModel>> getUnsyncedCategories() async {
    return await _offlineService.getUnsyncedCategories();
  }

  // ==================== BULK OPERATIONS ====================

  /// Save multiple categories (used by sync download)
  Future<void> saveCategories(List<CategoryModel> categories) async {
    await _offlineService.saveCategories(categories);
  }

  /// Clear all categories (dangerous - use with caution)
  Future<void> clearAllCategories() async {
    await _offlineService.clearAllCategories();
  }
}

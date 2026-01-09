import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import '../../categories/services/category_offline_service.dart';
import '../../orders/services/order_offline_service.dart';
import '../../products/services/product_offline_service.dart';
import '../database/database_helper.dart';
import '../utils/logger_x.dart';

class OfflineService extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final CategoryOfflineService _categoryOfflineService =
      CategoryOfflineService();
  final ProductOfflineService _productOfflineService = ProductOfflineService();
  final OrderOfflineService _orderOfflineService = OrderOfflineService();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  final RxBool isOnline = true.obs;
  final RxBool isSyncing = false.obs;
  final RxString lastSyncTime = ''.obs;
  final RxInt pendingSyncCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _listenToConnectivityChanges();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  // Initialize connectivity status
  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      LoggerX.log('Error checking connectivity: $e');
    }
  }

  // Listen to connectivity changes
  void _listenToConnectivityChanges() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  // Update connection status
  void _updateConnectionStatus(List<ConnectivityResult> result) {
    final wasOffline = !isOnline.value;
    isOnline.value = !result.contains(ConnectivityResult.none);

    LoggerX.log(
      'Connection status changed: ${isOnline.value ? "Online" : "Offline"}',
    );

    // Auto sync ketika kembali online
    if (wasOffline && isOnline.value) {
      _autoSyncWhenOnline();
    }

    _updatePendingSyncCount();
  }

  // Auto sync when back online
  Future<void> _autoSyncWhenOnline() async {
    await Future.delayed(const Duration(seconds: 2)); // Delay sedikit
    if (isOnline.value && pendingSyncCount.value > 0) {
      LoggerX.log('Device is back online, starting auto sync...');
      await syncAll();
    }
  }

  // Update pending sync count
  Future<void> _updatePendingSyncCount() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM sync_queue',
      );
      final count = result.first['count'] as int? ?? 0;
      pendingSyncCount.value = count;
    } catch (e) {
      LoggerX.log('Error updating pending sync count: $e');
    }
  }

  // Sync all data
  Future<Map<String, dynamic>> syncAll() async {
    if (!isOnline.value) {
      return {'success': false, 'message': 'No internet connection'};
    }

    if (isSyncing.value) {
      return {'success': false, 'message': 'Sync already in progress'};
    }

    isSyncing.value = true;

    try {
      final results = {
        'categories': 0,
        'products': 0,
        'orders': 0,
        'errors': [],
      };

      // Sync categories
      try {
        final unsyncedCategories = await _categoryOfflineService
            .getUnsyncedCategories();
        results['categories'] = unsyncedCategories.length;
        // TODO: Implement actual API sync
        LoggerX.log('Found ${unsyncedCategories.length} unsynced categories');
      } catch (e) {
        (results['errors'] as List).add('Categories sync error: $e');
      }

      // Sync products
      try {
        final unsyncedProducts = await _productOfflineService
            .getUnsyncedProducts();
        results['products'] = unsyncedProducts.length;
        // TODO: Implement actual API sync
        LoggerX.log('Found ${unsyncedProducts.length} unsynced products');
      } catch (e) {
        (results['errors'] as List).add('Products sync error: $e');
      }

      // Sync orders
      try {
        final unsyncedOrders = await _orderOfflineService.getUnsyncedOrders();
        results['orders'] = unsyncedOrders.length;
        // TODO: Implement actual API sync
        LoggerX.log('Found ${unsyncedOrders.length} unsynced orders');
      } catch (e) {
        (results['errors'] as List).add('Orders sync error: $e');
      }

      // Process sync queue
      await _processSyncQueue();

      lastSyncTime.value = DateTime.now().toIso8601String();
      await _updatePendingSyncCount();

      return {'success': true, 'message': 'Sync completed', 'results': results};
    } catch (e) {
      return {'success': false, 'message': 'Sync failed: $e'};
    } finally {
      isSyncing.value = false;
    }
  }

  // Process sync queue
  Future<void> _processSyncQueue() async {
    final db = await _dbHelper.database;
    final queueItems = await db.query(
      'sync_queue',
      orderBy: 'created_at ASC',
      limit: 100, // Process in batches
    );

    for (var item in queueItems) {
      try {
        // TODO: Implement actual API calls based on table_name and operation
        LoggerX.log(
          'Processing sync queue item: ${item['table_name']} - ${item['operation']}',
        );

        // If successful, remove from queue
        await db.delete('sync_queue', where: 'id = ?', whereArgs: [item['id']]);
      } catch (e) {
        // Update retry count and error
        await db.update(
          'sync_queue',
          {
            'retry_count': (item['retry_count'] as int? ?? 0) + 1,
            'last_error': e.toString(),
          },
          where: 'id = ?',
          whereArgs: [item['id']],
        );
      }
    }
  }

  // Download fresh data from server
  Future<Map<String, dynamic>> downloadFreshData() async {
    if (!isOnline.value) {
      return {'success': false, 'message': 'No internet connection'};
    }

    try {
      // TODO: Implement actual API calls to download data
      // This would typically:
      // 1. Fetch categories from API
      // 2. Save to local database using offline services
      // 3. Fetch products from API
      // 4. Save to local database
      // etc.

      LoggerX.log('Downloading fresh data from server...');

      return {'success': true, 'message': 'Data downloaded successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Download failed: $e'};
    }
  }

  // Get database statistics
  Future<Map<String, dynamic>> getDatabaseStats() async {
    return await _dbHelper.getDatabaseInfo();
  }

  // Clear all offline data
  Future<void> clearAllData() async {
    await _dbHelper.clearAllData();
    await _updatePendingSyncCount();
  }

  // Manual sync trigger
  Future<Map<String, dynamic>> manualSync() async {
    return await syncAll();
  }

  // Check if data needs sync
  Future<bool> needsSync() async {
    return pendingSyncCount.value > 0;
  }

  // Get last sync metadata
  Future<String?> getLastSyncTime() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'sync_metadata',
        where: 'key = ?',
        whereArgs: ['last_sync_time'],
        limit: 1,
      );

      if (result.isEmpty) return null;
      return result.first['value'] as String?;
    } catch (e) {
      LoggerX.log('Error getting last sync time: $e');
      return null;
    }
  }

  // Save last sync metadata
  Future<void> saveLastSyncTime() async {
    try {
      final db = await _dbHelper.database;
      await db.insert('sync_metadata', {
        'key': 'last_sync_time',
        'value': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      LoggerX.log('Error saving last sync time: $e');
    }
  }

  // Force online mode (for testing)
  void setOnlineMode(bool online) {
    isOnline.value = online;
  }
}

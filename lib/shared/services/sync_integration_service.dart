import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';

import '../../categories/models/category_model.dart';
import '../../categories/services/category_offline_service.dart';
import '../../home/models/product_model.dart';
import '../../orders/services/order_offline_service.dart';
import '../../products/services/product_offline_service.dart';
import '../models/sync_download_model.dart';
import '../models/sync_upload_model.dart';
import '../utils/logger_x.dart';
import 'sync_api_service.dart';

class SyncIntegrationService extends GetxController {
  final SyncApiService _syncApiService = SyncApiService();
  final CategoryOfflineService _categoryService = CategoryOfflineService();
  final ProductOfflineService _productService = ProductOfflineService();
  final OrderOfflineService _orderService = OrderOfflineService();

  String? _clientId;

  // Get or generate client ID (device UUID)
  Future<String> getClientId() async {
    if (_clientId != null) return _clientId!;

    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _clientId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _clientId = iosInfo.identifierForVendor ?? 'ios_device';
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        _clientId = macInfo.systemGUID ?? 'macos_device';
      } else {
        _clientId = 'unknown_device_${DateTime.now().millisecondsSinceEpoch}';
      }
    } catch (e) {
      _clientId = 'device_${DateTime.now().millisecondsSinceEpoch}';
      LoggerX.log('Error getting device ID: $e');
    }

    return _clientId!;
  }

  // Upload all unsynced data to server
  Future<SyncUploadResponse> uploadDataToServer({String? lastSyncAt}) async {
    final clientId = await getClientId();

    // Get unsynced data
    final unsyncedCategories = await _categoryService.getUnsyncedCategories();
    final unsyncedProducts = await _productService.getUnsyncedProducts();
    final unsyncedOrders = await _orderService.getUnsyncedOrders();

    // Convert to JSON format
    final categoriesJson = unsyncedCategories
        .map((cat) => _categoryToUploadFormat(cat))
        .toList();
    final productsJson = unsyncedProducts
        .map((prod) => _productToUploadFormat(prod))
        .toList();
    final ordersJson = unsyncedOrders
        .map((order) => _orderToUploadFormat(order))
        .toList();

    // Create request
    final request = SyncUploadRequest(
      clientId: clientId,
      clientTimestamp: DateTime.now().toUtc().toIso8601String(),
      categories: categoriesJson.isNotEmpty ? categoriesJson : null,
      products: productsJson.isNotEmpty ? productsJson : null,
      orders: ordersJson.isNotEmpty ? ordersJson : null,
      lastSyncAt: lastSyncAt,
    );

    // Upload to server
    final response = await _syncApiService.uploadData(request);

    // Update local database with server IDs
    await _updateLocalDataWithServerIds(response.data);

    return response;
  }

  // Download fresh data from server
  Future<SyncDownloadResponse> downloadDataFromServer({
    String? lastSyncAt,
    List<String>? entityTypes,
  }) async {
    final clientId = await getClientId();

    final request = SyncDownloadRequest(
      clientId: clientId,
      lastSyncAt: lastSyncAt,
      entityTypes:
          entityTypes ??
          ['categories', 'products', 'orders', 'tenants', 'branches', 'users'],
    );

    final response = await _syncApiService.downloadData(request);

    // Save downloaded data to local database
    await _saveDownloadedDataToLocal(response.data);

    return response;
  }

  // Get sync status from server
  Future<SyncStatusResponse> getSyncStatus() async {
    final clientId = await getClientId();
    return await _syncApiService.getSyncStatus(clientId);
  }

  // Convert CategoryModel to upload format
  Map<String, dynamic> _categoryToUploadFormat(CategoryModel category) {
    return {
      'local_id': 'cat_${category.id}',
      'tenant_id': category.tenantId,
      'name': category.name,
      'description': category.description,
      'is_active': category.isActive,
      'local_timestamp': _formatTimestamp(
        category.updatedAt ?? category.createdAt,
      ),
      'version': 1,
    };
  }

  // Convert ProductModel to upload format
  Map<String, dynamic> _productToUploadFormat(ProductModel product) {
    return {
      'local_id': 'prod_${product.id}',
      'category_id': product.categoryId,
      'name': product.name,
      'description': product.description,
      'sku': product.sku,
      'price': product.price,
      'stock': product.stock,
      'is_active': product.isActive,
      'local_timestamp': DateTime.now().toUtc().toIso8601String(),
      'version': 1,
    };
  }

  // Convert OrderOfflineModel to upload format
  Map<String, dynamic> _orderToUploadFormat(OrderOfflineModel order) {
    return {
      'local_id': 'order_${order.id}',
      'order_number': order.orderNumber,
      'tenant_id': order.tenantId,
      'branch_id': order.branchId,
      'user_id': order.userId,
      'customer_name': order.customerName,
      'customer_phone': order.customerPhone,
      'total_amount': order.totalAmount,
      'discount': order.discount,
      'tax': order.tax,
      'grand_total': order.grandTotal,
      'payment_method': order.paymentMethod,
      'payment_status': order.paymentStatus,
      'order_status': order.orderStatus,
      'notes': order.notes,
      'items': order.items
          .map(
            (item) => {
              'product_id': item.productId,
              'product_name': item.productName,
              'quantity': item.quantity,
              'price': item.price,
              'subtotal': item.subtotal,
              'notes': item.notes,
            },
          )
          .toList(),
      'local_timestamp': _formatTimestamp(order.createdAt),
      'version': 1,
    };
  }

  // Update local data with server IDs after successful upload
  Future<void> _updateLocalDataWithServerIds(SyncUploadData data) async {
    // Update categories
    for (var entry in data.categoryMapping.entries) {
      final localId = entry.key.replaceFirst('cat_', '');
      if (int.tryParse(localId) != null) {
        await _categoryService.markAsSynced(int.parse(localId));
      }
    }

    // Update products
    for (var entry in data.productMapping.entries) {
      final localId = entry.key.replaceFirst('prod_', '');
      if (int.tryParse(localId) != null) {
        await _productService.markAsSynced(int.parse(localId));
      }
    }

    // Update orders
    for (var entry in data.orderMapping.entries) {
      final localId = entry.key.replaceFirst('order_', '');
      final serverId = entry.value;
      if (int.tryParse(localId) != null) {
        await _orderService.markOrderAsSynced(int.parse(localId), serverId);
      }
    }
  }

  // Save downloaded data to local database
  Future<void> _saveDownloadedDataToLocal(SyncDownloadData data) async {
    LoggerX.log('🔄 Saving downloaded data to local database...');
    LoggerX.log(
      '📊 Data received - Products: ${data.products?.length ?? 0}, Categories: ${data.categories?.length ?? 0}',
    );

    // Save categories
    if (data.categories != null && data.categories!.isNotEmpty) {
      LoggerX.log('📁 Saving ${data.categories!.length} categories...');
      try {
        final categories = data.categories!
            .map((cat) => CategoryModel.fromJson(cat as Map<String, dynamic>))
            .toList();
        await _categoryService.saveCategories(categories);
        LoggerX.log('✅ Categories saved successfully');
      } catch (e, stackTrace) {
        LoggerX.log('❌ Error saving categories: $e');
        LoggerX.log('Stack trace: $stackTrace');
      }
    } else {
      LoggerX.log(
        '⚠️ No categories to save (null: ${data.categories == null}, empty: ${data.categories?.isEmpty})',
      );
    }

    // Save products
    if (data.products != null && data.products!.isNotEmpty) {
      LoggerX.log('📦 Saving ${data.products!.length} products...');
      try {
        final products = data.products!
            .map((prod) => ProductModel.fromJson(prod as Map<String, dynamic>))
            .toList();
        await _productService.saveProducts(products);
        LoggerX.log('✅ Products saved successfully');
      } catch (e, stackTrace) {
        LoggerX.log('❌ Error saving products: $e');
        LoggerX.log('Stack trace: $stackTrace');
      }
    } else {
      LoggerX.log(
        '⚠️ No products to save (null: ${data.products == null}, empty: ${data.products?.isEmpty})',
      );
    }

    // TODO: Add support for saving tenants, branches, users, and orders when offline services are ready
    // Currently only categories and products have offline support with auto-sync
    LoggerX.log(
      '📋 Other entities (tenants, branches, users, orders) will be synced once offline services are implemented',
    );
  }

  // Full bidirectional sync
  Future<Map<String, dynamic>> performFullSync() async {
    try {
      // Step 1: Get server time for sync reference
      final serverTime = await _syncApiService.getServerTime();

      // Step 2: Upload unsynced data
      final uploadResponse = await uploadDataToServer();

      // Step 3: Download fresh data
      final downloadResponse = await downloadDataFromServer();

      return {
        'success': true,
        'uploaded': uploadResponse.data.totalProcessed,
        'downloaded': downloadResponse.data.totalDownloaded,
        'failed': uploadResponse.data.totalFailed,
        'has_conflicts': uploadResponse.data.hasConflicts,
        'sync_timestamp': serverTime.toUtc().toIso8601String(),
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Helper method to ensure timestamps have timezone information
  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) {
      return DateTime.now().toUtc().toIso8601String();
    }

    try {
      // Try to parse the timestamp
      final dt = DateTime.parse(timestamp);

      // If it's already UTC or has timezone, convert to UTC and format
      // Otherwise assume local time and convert to UTC
      if (dt.isUtc) {
        return dt.toIso8601String();
      } else {
        return dt.toUtc().toIso8601String();
      }
    } catch (e) {
      // If parsing fails, return current time in UTC
      LoggerX.log('Error parsing timestamp: $timestamp, using current time');
      return DateTime.now().toUtc().toIso8601String();
    }
  }
}

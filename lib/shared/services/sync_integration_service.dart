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
      print('Error getting device ID: $e');
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
      clientTimestamp: DateTime.now().toIso8601String(),
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
      entityTypes: entityTypes ?? ['categories', 'products'],
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
      'local_timestamp': category.updatedAt ?? category.createdAt,
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
      'local_timestamp': DateTime.now().toIso8601String(),
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
      'local_timestamp': order.createdAt,
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
    // Save categories
    if (data.categories != null && data.categories!.isNotEmpty) {
      final categories = data.categories!
          .map((cat) => CategoryModel.fromJson(cat as Map<String, dynamic>))
          .toList();
      await _categoryService.saveCategories(categories);
    }

    // Save products
    if (data.products != null && data.products!.isNotEmpty) {
      final products = data.products!
          .map((prod) => ProductModel.fromJson(prod as Map<String, dynamic>))
          .toList();
      await _productService.saveProducts(products);
    }

    // Additional entity types can be added here
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
        'sync_timestamp': serverTime.toIso8601String(),
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}

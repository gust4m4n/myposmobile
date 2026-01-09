import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';

import '../../branches/models/branch_model.dart';
import '../../branches/services/branch_offline_service.dart';
import '../../branches/services/branches_management_service.dart';
import '../../categories/models/category_model.dart';
import '../../categories/services/categories_management_service.dart';
import '../../categories/services/category_offline_service.dart';
import '../../home/models/product_model.dart';
import '../../orders/services/order_offline_service.dart';
import '../../orders/services/orders_management_service.dart';
import '../../payments/services/payment_offline_service.dart';
import '../../payments/services/payments_management_service.dart';
import '../../products/services/product_offline_service.dart';
import '../../products/services/products_management_service.dart';
import '../../tenants/models/tenant_model.dart';
import '../../tenants/services/tenant_offline_service.dart';
import '../../tenants/services/tenants_management_service.dart';
import '../../users/models/user_management_model.dart';
import '../../users/services/user_offline_service.dart';
import '../../users/services/users_management_service.dart';
import '../models/sync_download_model.dart';
import '../models/sync_upload_model.dart';
import '../utils/logger_x.dart';
import 'sync_api_service.dart';

class SyncIntegrationService extends GetxController {
  final SyncApiService _syncApiService = SyncApiService();
  final CategoryOfflineService _categoryService = CategoryOfflineService();
  final ProductOfflineService _productService = ProductOfflineService();
  final OrderOfflineService _orderService = OrderOfflineService();
  final PaymentOfflineService _paymentService = PaymentOfflineService();
  final TenantOfflineService _tenantService = TenantOfflineService();
  final BranchOfflineService _branchService = BranchOfflineService();
  final UserOfflineService _userService = UserOfflineService();

  // Management services for fallback sync
  final TenantsManagementService _tenantsManagement =
      TenantsManagementService();
  final BranchesManagementService _branchesManagement =
      BranchesManagementService();
  final CategoriesManagementService _categoriesManagement =
      CategoriesManagementService();
  final OrdersManagementService _ordersManagement = OrdersManagementService();
  final PaymentsManagementService _paymentsManagement =
      PaymentsManagementService();

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
          [
            'categories',
            'products',
            'orders',
            'payments',
            'tenants',
            'branches',
            'users',
          ],
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
  Future<Map<String, int>> _saveDownloadedDataToLocal(
    SyncDownloadData data,
  ) async {
    LoggerX.log('🔄 Saving downloaded data to local database...');

    // Debug: Log what we received from API
    LoggerX.log('📊 API Response Summary:');
    LoggerX.log(
      '   Tenants: ${data.tenants?.length ?? 0} (null: ${data.tenants == null})',
    );
    LoggerX.log(
      '   Branches: ${data.branches?.length ?? 0} (null: ${data.branches == null})',
    );
    LoggerX.log(
      '   Users: ${data.users?.length ?? 0} (null: ${data.users == null})',
    );
    LoggerX.log(
      '   Categories: ${data.categories?.length ?? 0} (null: ${data.categories == null})',
    );
    LoggerX.log(
      '   Products: ${data.products?.length ?? 0} (null: ${data.products == null})',
    );
    LoggerX.log(
      '   Orders: ${data.orders?.length ?? 0} (null: ${data.orders == null})',
    );
    LoggerX.log(
      '   Payments: ${data.payments?.length ?? 0} (null: ${data.payments == null})',
    );

    final counts = <String, int>{
      'tenants': 0,
      'branches': 0,
      'users': 0,
      'categories': 0,
      'products': 0,
      'orders': 0,
      'payments': 0,
    };

    // Save tenants
    if (data.tenants != null && data.tenants!.isNotEmpty) {
      LoggerX.log('🏢 Saving ${data.tenants!.length} tenants...');
      try {
        final tenants = data.tenants!
            .map(
              (tenant) => TenantModel.fromJson(tenant as Map<String, dynamic>),
            )
            .toList();
        await _tenantService.saveTenants(tenants);
        counts['tenants'] = tenants.length;
        LoggerX.log('✅ Tenants saved successfully');
      } catch (e, stackTrace) {
        LoggerX.log('❌ Error saving tenants: $e');
        LoggerX.log('Stack trace: $stackTrace');
      }
    }

    // Save branches
    if (data.branches != null && data.branches!.isNotEmpty) {
      LoggerX.log('🏪 Saving ${data.branches!.length} branches...');
      try {
        final branches = data.branches!
            .map(
              (branch) => BranchModel.fromJson(branch as Map<String, dynamic>),
            )
            .toList();
        await _branchService.saveBranches(branches);
        counts['branches'] = branches.length;
        LoggerX.log('✅ Branches saved successfully');
      } catch (e, stackTrace) {
        LoggerX.log('❌ Error saving branches: $e');
        LoggerX.log('Stack trace: $stackTrace');
      }
    }

    // Save users
    if (data.users != null && data.users!.isNotEmpty) {
      LoggerX.log('👥 Saving ${data.users!.length} users...');
      try {
        final users = data.users!
            .map(
              (user) =>
                  UserManagementModel.fromJson(user as Map<String, dynamic>),
            )
            .toList();
        await _userService.saveUsers(users);
        counts['users'] = users.length;
        LoggerX.log('✅ Users saved successfully');
      } catch (e, stackTrace) {
        LoggerX.log('❌ Error saving users: $e');
        LoggerX.log('Stack trace: $stackTrace');
      }
    }

    // Save categories
    if (data.categories != null && data.categories!.isNotEmpty) {
      LoggerX.log('📁 Saving ${data.categories!.length} categories...');
      try {
        final categories = data.categories!
            .map((cat) => CategoryModel.fromJson(cat as Map<String, dynamic>))
            .toList();
        await _categoryService.saveCategories(categories);
        counts['categories'] = categories.length;
        LoggerX.log('✅ Categories saved successfully');
      } catch (e, stackTrace) {
        LoggerX.log('❌ Error saving categories: $e');
        LoggerX.log('Stack trace: $stackTrace');
      }
    }

    // Save products
    if (data.products != null && data.products!.isNotEmpty) {
      LoggerX.log('📦 Saving ${data.products!.length} products...');
      try {
        final products = data.products!
            .map((prod) => ProductModel.fromJson(prod as Map<String, dynamic>))
            .toList();
        await _productService.saveProducts(products);
        counts['products'] = products.length;
        LoggerX.log('✅ Products saved successfully');
      } catch (e, stackTrace) {
        LoggerX.log('❌ Error saving products: $e');
        LoggerX.log('Stack trace: $stackTrace');
      }
    }

    // Save orders
    if (data.orders != null && data.orders!.isNotEmpty) {
      LoggerX.log('📋 Saving ${data.orders!.length} orders...');
      try {
        final orders = data.orders!
            .map((order) => order as Map<String, dynamic>)
            .toList();
        await _orderService.saveOrders(orders);
        counts['orders'] = orders.length;
        LoggerX.log('✅ Orders saved successfully');
      } catch (e, stackTrace) {
        LoggerX.log('❌ Error saving orders: $e');
        LoggerX.log('Stack trace: $stackTrace');
      }
    }

    // Save payments
    if (data.payments != null && data.payments!.isNotEmpty) {
      LoggerX.log('💳 Saving ${data.payments!.length} payments...');
      try {
        final payments = data.payments!
            .map((payment) => payment as Map<String, dynamic>)
            .toList();
        await _paymentService.savePayments(payments);
        counts['payments'] = payments.length;
        LoggerX.log('✅ Payments saved successfully');
      } catch (e, stackTrace) {
        LoggerX.log('❌ Error saving payments: $e');
        LoggerX.log('Stack trace: $stackTrace');
      }
    }

    return counts;
  }

  // Full bidirectional sync
  Future<Map<String, dynamic>> performFullSync() async {
    try {
      LoggerX.log('🚀 Starting full sync...');

      // Step 1: Get server time for sync reference
      final serverTime = await _syncApiService.getServerTime();
      LoggerX.log('🕐 Server time: ${serverTime.toIso8601String()}');

      // Step 2: Upload unsynced data
      LoggerX.log('⬆️  Uploading local changes...');
      final uploadResponse = await uploadDataToServer();
      LoggerX.log(
        '✅ Upload complete: ${uploadResponse.data.totalProcessed} items processed',
      );

      // Step 3: Download fresh data
      LoggerX.log('⬇️  Downloading data from server...');
      final downloadResponse = await downloadDataFromServer();

      // Step 4: Save to local DB and get counts
      final savedCounts = await _saveDownloadedDataToLocal(
        downloadResponse.data,
      );

      // Step 5: Fallback - sync directly from management services if sync API didn't provide data
      await _syncFromManagementServices(savedCounts);

      // Display summary
      LoggerX.log('\n${'=' * 60}');
      LoggerX.log('📊 FULL SYNC COMPLETED SUCCESSFULLY');
      LoggerX.log('=' * 60);
      LoggerX.log('📥 Downloaded and Saved to Local DB:');
      LoggerX.log(
        '   🏢 Tenants:    ${savedCounts['tenants']?.toString().padLeft(4)} records',
      );
      LoggerX.log(
        '   🏪 Branches:   ${savedCounts['branches']?.toString().padLeft(4)} records',
      );
      LoggerX.log(
        '   👥 Users:      ${savedCounts['users']?.toString().padLeft(4)} records',
      );
      LoggerX.log(
        '   📁 Categories: ${savedCounts['categories']?.toString().padLeft(4)} records',
      );
      LoggerX.log(
        '   📦 Products:   ${savedCounts['products']?.toString().padLeft(4)} records',
      );
      LoggerX.log(
        '   📋 Orders:     ${savedCounts['orders']?.toString().padLeft(4)} records',
      );
      LoggerX.log(
        '   💳 Payments:   ${savedCounts['payments']?.toString().padLeft(4)} records',
      );
      final totalSaved = savedCounts.values.fold<int>(
        0,
        (sum, count) => sum + count,
      );
      LoggerX.log('   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      LoggerX.log(
        '   📊 Total:      ${totalSaved.toString().padLeft(4)} records',
      );
      LoggerX.log('');
      LoggerX.log('📤 Uploaded to Server:');
      LoggerX.log('   ✅ Processed: ${uploadResponse.data.totalProcessed}');
      LoggerX.log('   ❌ Failed:    ${uploadResponse.data.totalFailed}');
      if (uploadResponse.data.hasConflicts) {
        LoggerX.log('   ⚠️  Conflicts detected');
      }
      LoggerX.log('=' * 60 + '\n');

      return {
        'success': true,
        'uploaded': uploadResponse.data.totalProcessed,
        'downloaded': downloadResponse.data.totalDownloaded,
        'saved_counts': savedCounts,
        'total_saved': totalSaved,
        'failed': uploadResponse.data.totalFailed,
        'has_conflicts': uploadResponse.data.hasConflicts,
        'sync_timestamp': serverTime.toUtc().toIso8601String(),
      };
    } catch (e) {
      LoggerX.log('❌ Full sync failed: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Fallback: Sync directly from management services if sync API didn't provide data
  Future<void> _syncFromManagementServices(Map<String, int> savedCounts) async {
    LoggerX.log(
      '\n🔄 Checking for missing entities and syncing directly from APIs...',
    );

    try {
      // Sync tenants if none were saved
      if (savedCounts['tenants'] == 0) {
        LoggerX.log('🏢 Syncing tenants directly from management API...');
        await _tenantsManagement.syncTenantsFromServer();
        final count = await _tenantService.getTenantCount();
        savedCounts['tenants'] = count;
        LoggerX.log('✅ Synced $count tenants');
      }

      // Sync branches if none were saved
      if (savedCounts['branches'] == 0) {
        LoggerX.log('🏪 Syncing branches directly from management API...');
        await _branchesManagement.syncBranchesFromServer();
        final count = await _branchService.getBranchCount();
        savedCounts['branches'] = count;
        LoggerX.log('✅ Synced $count branches');
      }

      // Sync users if none were saved
      if (savedCounts['users'] == 0) {
        LoggerX.log('👥 Syncing users directly from management API...');
        await UsersManagementService.syncUsersFromServer();
        final count = await _userService.getUserCount();
        savedCounts['users'] = count;
        LoggerX.log('✅ Synced $count users');
      }

      // Sync categories if none were saved
      if (savedCounts['categories'] == 0) {
        LoggerX.log('📁 Syncing categories directly from management API...');
        await _categoriesManagement.syncCategoriesFromServer();
        final count = await _categoryService.getCategoryCount();
        savedCounts['categories'] = count;
        LoggerX.log('✅ Synced $count categories');
      }

      // Sync products if none were saved
      if (savedCounts['products'] == 0) {
        LoggerX.log('📦 Syncing products directly from management API...');
        await ProductsManagementService.syncProductsFromServer();
        final count = await _productService.getProductsCount();
        savedCounts['products'] = count;
        LoggerX.log('✅ Synced $count products');
      }

      // Sync orders if none were saved
      if (savedCounts['orders'] == 0) {
        LoggerX.log('📋 Syncing orders directly from management API...');
        await _ordersManagement.syncOrdersFromServer();
        final count = await _orderService.getOrdersCount();
        savedCounts['orders'] = count;
        LoggerX.log('✅ Synced $count orders');
      }

      // Sync payments if none were saved
      if (savedCounts['payments'] == 0) {
        LoggerX.log('💳 Syncing payments directly from management API...');
        await _paymentsManagement.syncPaymentsFromServer();
        final count = await _paymentService.getPaymentsCount();
        savedCounts['payments'] = count;
        LoggerX.log('✅ Synced $count payments');
      }

      LoggerX.log('✅ Fallback sync completed\n');
    } catch (e) {
      LoggerX.log('⚠️  Fallback sync error: $e');
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

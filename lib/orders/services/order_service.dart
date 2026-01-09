import 'package:get/get.dart';

import '../../products/services/product_service.dart';
import '../../shared/api_models.dart';
import '../../shared/controllers/offline_controller.dart';
import '../../shared/controllers/profile_controller.dart';
import '../../shared/utils/logger_x.dart';
import 'order_offline_service.dart';
import 'orders_service.dart';

/// Main Order Service with offline-first approach
/// Routes to local DB when offline mode is enabled, otherwise uses API
class OrderService {
  final OrderOfflineService _offlineService = OrderOfflineService();

  /// Create order - routes to local DB in offline mode, otherwise uses API
  Future<ApiResponse<Map<String, dynamic>>> createOrder({
    required List<Map<String, dynamic>> items,
    String? notes,
  }) async {
    // Check if offline mode is enabled
    final offlineController = Get.find<OfflineController>();
    final isOfflineMode = offlineController.isOfflineModeEnabled.value;

    if (isOfflineMode || !offlineController.isOnline.value) {
      // Offline mode - create in local database
      LoggerX.log('📴 Offline mode: Creating order in local database');
      return await _createOrderOffline(items: items, notes: notes);
    } else {
      // Online mode - use API
      LoggerX.log('🌐 Online mode: Creating order via API');
      return await OrdersService.createOrder(items: items, notes: notes);
    }
  }

  /// Create order in local database
  Future<ApiResponse<Map<String, dynamic>>> _createOrderOffline({
    required List<Map<String, dynamic>> items,
    String? notes,
  }) async {
    try {
      // Get profile info
      final profileController = Get.find<ProfileController>();
      final profile = profileController.profile.value;

      if (profile == null) {
        return ApiResponse<Map<String, dynamic>>(
          statusCode: 400,
          message: 'Profile not loaded',
          error: 'User profile is required to create order',
        );
      }

      // Calculate totals from actual product prices
      final productService = Get.find<ProductService>();
      double totalAmount = 0;
      final List<OrderItemOfflineModel> orderItems = [];

      for (var item in items) {
        final productId = item['product_id'] as int;
        final quantity = item['quantity'] as int;

        // Fetch product from local database to get price
        final product = await productService.getProductById(productId);

        if (product == null) {
          return ApiResponse<Map<String, dynamic>>(
            statusCode: 400,
            message: 'Product not found: $productId',
            error: 'Product with ID $productId does not exist',
          );
        }

        final unitPrice = product.price;
        final subtotal = unitPrice * quantity;
        totalAmount += subtotal;

        orderItems.add(
          OrderItemOfflineModel(
            orderId: 0, // Will be set when saving
            productId: productId,
            productName: product.name,
            quantity: quantity,
            price: unitPrice,
            subtotal: subtotal,
            notes: item['notes'] as String?,
          ),
        );
      }

      final discount = 0.0;
      final tax = 0.0;
      final grandTotal = totalAmount - discount + tax;

      // Create order model
      final orderNumber = _offlineService.generateOrderNumber();
      final order = OrderOfflineModel(
        orderNumber: orderNumber,
        tenantId: profile.tenant.id,
        branchId: profile.branch.id,
        userId: profile.user.id,
        totalAmount: totalAmount,
        discount: discount,
        tax: tax,
        grandTotal: grandTotal,
        paymentMethod: 'pending',
        paymentStatus: 'pending',
        orderStatus: 'pending',
        notes: notes,
        createdAt: DateTime.now().toUtc().toIso8601String(),
        items: orderItems,
      );

      // Save to local database
      final savedOrder = await _offlineService.createOrder(order);

      LoggerX.log('✅ Order created offline: ${savedOrder.orderNumber}');

      // Convert to API response format
      return ApiResponse<Map<String, dynamic>>(
        statusCode: 200,
        message: 'Order created successfully (offline)',
        data: {
          'id': savedOrder.id,
          'order_number': savedOrder.orderNumber,
          'total_amount': savedOrder.totalAmount,
          'discount': savedOrder.discount,
          'tax': savedOrder.tax,
          'grand_total': savedOrder.grandTotal,
          'payment_method': savedOrder.paymentMethod,
          'payment_status': savedOrder.paymentStatus,
          'order_status': savedOrder.orderStatus,
          'notes': savedOrder.notes,
          'created_at': savedOrder.createdAt,
          'items': savedOrder.items.map((item) => item.toMap()).toList(),
        },
      );
    } catch (e) {
      LoggerX.log('❌ Error creating order offline: $e');
      return ApiResponse<Map<String, dynamic>>(
        statusCode: 500,
        message: 'Failed to create order offline',
        error: e.toString(),
      );
    }
  }

  /// Get orders - routes to local DB in offline mode
  Future<ApiResponse<Map<String, dynamic>>> getOrders({
    int page = 1,
    int perPage = 32,
  }) async {
    final offlineController = Get.find<OfflineController>();
    final isOfflineMode = offlineController.isOfflineModeEnabled.value;

    if (isOfflineMode || !offlineController.isOnline.value) {
      // Offline mode - get from local database
      LoggerX.log('📴 Offline mode: Getting orders from local database');
      return await _getOrdersOffline(page: page, perPage: perPage);
    } else {
      // Online mode - use API
      return await OrdersService.getOrders(page: page, perPage: perPage);
    }
  }

  /// Get orders from local database
  Future<ApiResponse<Map<String, dynamic>>> _getOrdersOffline({
    int page = 1,
    int perPage = 32,
  }) async {
    try {
      final orders = await _offlineService.getAllOrders();

      // Apply pagination
      final startIndex = (page - 1) * perPage;
      final paginatedOrders = orders.skip(startIndex).take(perPage).toList();

      return ApiResponse<Map<String, dynamic>>(
        statusCode: 200,
        message: 'Orders retrieved from local database',
        data: {
          'data': paginatedOrders
              .map(
                (o) => {
                  'id': o.id,
                  'order_number': o.orderNumber,
                  'total_amount': o.totalAmount,
                  'grand_total': o.grandTotal,
                  'payment_status': o.paymentStatus,
                  'order_status': o.orderStatus,
                  'created_at': o.createdAt,
                },
              )
              .toList(),
          'pagination': {
            'page': page,
            'per_page': perPage,
            'total': orders.length,
            'total_pages': (orders.length / perPage).ceil(),
          },
        },
      );
    } catch (e) {
      LoggerX.log('❌ Error getting orders offline: $e');
      return ApiResponse<Map<String, dynamic>>(
        statusCode: 500,
        message: 'Failed to get orders offline',
        error: e.toString(),
      );
    }
  }

  /// Get order by ID
  Future<ApiResponse<Map<String, dynamic>>> getOrderById(int orderId) async {
    final offlineController = Get.find<OfflineController>();
    final isOfflineMode = offlineController.isOfflineModeEnabled.value;

    if (isOfflineMode || !offlineController.isOnline.value) {
      LoggerX.log('📴 Offline mode: Getting order from local database');
      return await _getOrderByIdOffline(orderId);
    } else {
      return await OrdersService.getOrderById(orderId);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> _getOrderByIdOffline(
    int orderId,
  ) async {
    try {
      final order = await _offlineService.getOrderById(orderId);

      if (order == null) {
        return ApiResponse<Map<String, dynamic>>(
          statusCode: 404,
          message: 'Order not found',
        );
      }

      return ApiResponse<Map<String, dynamic>>(
        statusCode: 200,
        message: 'Order retrieved from local database',
        data: {
          'id': order.id,
          'order_number': order.orderNumber,
          'total_amount': order.totalAmount,
          'discount': order.discount,
          'tax': order.tax,
          'grand_total': order.grandTotal,
          'payment_method': order.paymentMethod,
          'payment_status': order.paymentStatus,
          'order_status': order.orderStatus,
          'notes': order.notes,
          'created_at': order.createdAt,
          'items': order.items.map((item) => item.toMap()).toList(),
        },
      );
    } catch (e) {
      LoggerX.log('❌ Error getting order offline: $e');
      return ApiResponse<Map<String, dynamic>>(
        statusCode: 500,
        message: 'Failed to get order offline',
        error: e.toString(),
      );
    }
  }
}

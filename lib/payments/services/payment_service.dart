import 'dart:convert';

import 'package:get/get.dart';

import '../../orders/services/order_offline_service.dart';
import '../../shared/api_models.dart';
import '../../shared/controllers/offline_controller.dart';
import '../../shared/database/database_helper.dart';
import '../../shared/utils/logger_x.dart';
import 'payments_service.dart';

/// Main Payment Service with offline-first approach
/// Routes to local DB when offline mode is enabled, otherwise uses API
class PaymentService {
  final OrderOfflineService _orderOfflineService = OrderOfflineService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Create payment - routes to local DB in offline mode, otherwise uses API
  Future<ApiResponse<Map<String, dynamic>>> createPayment({
    required int orderId,
    required double amount,
    required String paymentMethod,
    String? notes,
  }) async {
    // Check if offline mode is enabled
    final offlineController = Get.find<OfflineController>();
    final isOfflineMode = offlineController.isOfflineModeEnabled.value;

    if (isOfflineMode || !offlineController.isOnline.value) {
      // Offline mode - create payment in local database
      LoggerX.log('📴 Offline mode: Creating payment in local database');
      return await _createPaymentOffline(
        orderId: orderId,
        amount: amount,
        paymentMethod: paymentMethod,
        notes: notes,
      );
    } else {
      // Online mode - use API
      LoggerX.log('🌐 Online mode: Creating payment via API');
      return await PaymentsService.createPayment(
        orderId: orderId,
        amount: amount,
        paymentMethod: paymentMethod,
        notes: notes,
      );
    }
  }

  /// Create payment in local database by updating order
  Future<ApiResponse<Map<String, dynamic>>> _createPaymentOffline({
    required int orderId,
    required double amount,
    required String paymentMethod,
    String? notes,
  }) async {
    try {
      // Get order from local database
      final order = await _orderOfflineService.getOrderById(orderId);

      if (order == null) {
        return ApiResponse<Map<String, dynamic>>(
          statusCode: 404,
          message: 'Order not found',
          error: 'Order with ID $orderId does not exist',
        );
      }

      // Validate payment amount
      if (amount < order.grandTotal) {
        return ApiResponse<Map<String, dynamic>>(
          statusCode: 400,
          message: 'Payment amount insufficient',
          error: 'Payment amount must be >= order total (${order.grandTotal})',
        );
      }

      // Update order with payment info in local database
      final db = await _dbHelper.database;

      await db.update(
        'orders',
        {
          'payment_method': paymentMethod,
          'payment_status': 'paid',
          'order_status': 'completed',
          'updated_at': DateTime.now().toUtc().toIso8601String(),
          'synced': 0,
        },
        where: 'id = ?',
        whereArgs: [orderId],
      );

      // Add to sync queue for payment update
      await db.insert('sync_queue', {
        'table_name': 'orders',
        'record_id': orderId,
        'operation': 'UPDATE',
        'data': jsonEncode({
          'payment_method': paymentMethod,
          'payment_status': 'paid',
          'order_status': 'completed',
          'payment_amount': amount,
          'payment_notes': notes,
        }),
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'retry_count': 0,
      });

      LoggerX.log('✅ Payment created offline for order: ${order.orderNumber}');

      // Generate payment ID (timestamp-based)
      final paymentId = DateTime.now().millisecondsSinceEpoch;

      // Return payment response in API format
      return ApiResponse<Map<String, dynamic>>(
        statusCode: 200,
        message: 'Payment created successfully (offline)',
        data: {
          'id': paymentId,
          'order_id': orderId,
          'order_number': order.orderNumber,
          'amount': amount,
          'payment_method': paymentMethod,
          'payment_status': 'paid',
          'notes': notes,
          'created_at': DateTime.now().toUtc().toIso8601String(),
          'order': {
            'id': order.id,
            'order_number': order.orderNumber,
            'grand_total': order.grandTotal,
            'order_status': 'completed',
            'payment_status': 'paid',
          },
        },
      );
    } catch (e) {
      LoggerX.log('❌ Error creating payment offline: $e');
      return ApiResponse<Map<String, dynamic>>(
        statusCode: 500,
        message: 'Failed to create payment offline',
        error: e.toString(),
      );
    }
  }

  /// Get payments - routes to local DB in offline mode
  Future<ApiResponse<Map<String, dynamic>>> getPayments({
    int page = 1,
    int perPage = 32,
  }) async {
    final offlineController = Get.find<OfflineController>();
    final isOfflineMode = offlineController.isOfflineModeEnabled.value;

    if (isOfflineMode || !offlineController.isOnline.value) {
      // Offline mode - get paid orders from local database
      LoggerX.log('📴 Offline mode: Getting payments from local database');
      return await _getPaymentsOffline(page: page, perPage: perPage);
    } else {
      // Online mode - use API
      return await PaymentsService.getPayments(page: page, perPage: perPage);
    }
  }

  /// Get payments from local database (paid orders)
  Future<ApiResponse<Map<String, dynamic>>> _getPaymentsOffline({
    int page = 1,
    int perPage = 32,
  }) async {
    try {
      // Get all paid orders
      final allOrders = await _orderOfflineService.getAllOrders();
      final paidOrders = allOrders
          .where((o) => o.paymentStatus == 'paid')
          .toList();

      // Apply pagination
      final startIndex = (page - 1) * perPage;
      final paginatedOrders = paidOrders
          .skip(startIndex)
          .take(perPage)
          .toList();

      return ApiResponse<Map<String, dynamic>>(
        statusCode: 200,
        message: 'Payments retrieved from local database',
        data: {
          'data': paginatedOrders
              .map(
                (o) => {
                  'id': o.id,
                  'order_id': o.id,
                  'order_number': o.orderNumber,
                  'amount': o.grandTotal,
                  'payment_method': o.paymentMethod,
                  'payment_status': o.paymentStatus,
                  'created_at': o.createdAt,
                },
              )
              .toList(),
          'pagination': {
            'page': page,
            'per_page': perPage,
            'total': paidOrders.length,
            'total_pages': (paidOrders.length / perPage).ceil(),
          },
        },
      );
    } catch (e) {
      LoggerX.log('❌ Error getting payments offline: $e');
      return ApiResponse<Map<String, dynamic>>(
        statusCode: 500,
        message: 'Failed to get payments offline',
        error: e.toString(),
      );
    }
  }
}

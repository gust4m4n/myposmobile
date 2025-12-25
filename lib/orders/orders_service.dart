import 'dart:convert';

import '../shared/api_models.dart';
import '../shared/config/api_config.dart';
import '../shared/utils/http_client.dart';

/// Service untuk operasi orders (Create, List, Get by ID, Get Payments).
/// Memerlukan JWT token untuk authentication.
class OrdersService {
  /// Create new order with multiple products
  ///
  /// Parameters:
  /// - items: List of order items with product_id and quantity
  /// - notes: Optional order notes
  ///
  /// Returns:
  /// - Map<String, dynamic> berisi order details dengan order number dan total
  ///
  /// Example:
  /// ```dart
  /// final result = await OrdersService.createOrder(
  ///   items: [
  ///     {'product_id': 27, 'quantity': 2},
  ///     {'product_id': 42, 'quantity': 3},
  ///   ],
  ///   notes: 'Customer order from table 5',
  /// );
  /// ```
  static Future<ApiResponse<Map<String, dynamic>>> createOrder({
    required List<Map<String, dynamic>> items,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{'items': items};
      if (notes != null && notes.isNotEmpty) {
        body['notes'] = notes;
      }

      final response = await HttpClient().post(
        ApiConfig.orders,
        body: body,
        requiresAuth: true,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          data: data['data'] as Map<String, dynamic>,
          message: data['message'] ?? 'Order created successfully',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          error: errorData['error'] ?? 'Failed to create order',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        error: 'Error creating order: $e',
      );
    }
  }

  /// Get list of all orders for authenticated tenant and branch
  ///
  /// Returns:
  /// - List<Map<String, dynamic>> berisi semua orders dengan items
  ///
  /// Example:
  /// ```dart
  /// final result = await OrdersService.getOrders();
  /// ```
  static Future<ApiResponse<List<Map<String, dynamic>>>> getOrders() async {
    try {
      final response = await HttpClient().get(
        ApiConfig.orders,
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final orders = (data['data'] as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();

        return ApiResponse<List<Map<String, dynamic>>>(
          data: orders,
          message: data['message'] ?? 'Orders retrieved successfully',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse<List<Map<String, dynamic>>>(
          error: errorData['error'] ?? 'Failed to get orders',
        );
      }
    } catch (e) {
      return ApiResponse<List<Map<String, dynamic>>>(
        error: 'Error getting orders: $e',
      );
    }
  }

  /// Get order details by ID
  ///
  /// Parameters:
  /// - orderId: ID of the order
  ///
  /// Returns:
  /// - Map<String, dynamic> berisi detail order lengkap dengan items
  ///
  /// Example:
  /// ```dart
  /// final result = await OrdersService.getOrderById(3);
  /// ```
  static Future<ApiResponse<Map<String, dynamic>>> getOrderById(
    int orderId,
  ) async {
    try {
      final response = await HttpClient().get(
        '${ApiConfig.orders}/$orderId',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          data: data['data'] as Map<String, dynamic>,
          message: data['message'] ?? 'Order retrieved successfully',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          error: errorData['error'] ?? 'Failed to get order',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        error: 'Error getting order: $e',
      );
    }
  }

  /// Get all payments for a specific order
  ///
  /// Parameters:
  /// - orderId: ID of the order
  ///
  /// Returns:
  /// - List<Map<String, dynamic>> berisi payment history untuk order
  ///
  /// Example:
  /// ```dart
  /// final result = await OrdersService.getOrderPayments(3);
  /// ```
  static Future<ApiResponse<List<Map<String, dynamic>>>> getOrderPayments(
    int orderId,
  ) async {
    try {
      final response = await HttpClient().get(
        '${ApiConfig.orders}/$orderId/payments',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final payments = (data['data'] as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();

        return ApiResponse<List<Map<String, dynamic>>>(
          data: payments,
          message: data['message'] ?? 'Payments retrieved successfully',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse<List<Map<String, dynamic>>>(
          error: errorData['error'] ?? 'Failed to get payments',
        );
      }
    } catch (e) {
      return ApiResponse<List<Map<String, dynamic>>>(
        error: 'Error getting payments: $e',
      );
    }
  }
}

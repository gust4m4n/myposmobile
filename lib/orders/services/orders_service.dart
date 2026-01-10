import '../../shared/api_models.dart';
import '../../shared/utils/api_x.dart';

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
    final body = <String, dynamic>{'items': items};
    if (notes != null && notes.isNotEmpty) {
      body['notes'] = notes;
    }

    return ApiX.post<Map<String, dynamic>>(
      '/orders',
      body: body,
      requiresAuth: true,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// Get list of all orders for authenticated tenant and branch
  ///
  /// Parameters:
  /// - page: Page number (default: 1)
  /// - perPage: Items per page (default: 32, max: 100)
  ///
  /// Returns:
  /// - Map<String, dynamic> berisi:
  ///   - data: List<Map<String, dynamic>> semua orders dengan items
  ///   - pagination: Map berisi page, per_page, total, total_pages
  ///
  /// Example:
  /// ```dart
  /// final result = await OrdersService.getOrders(page: 1, perPage: 32);
  /// ```
  static Future<ApiResponse<Map<String, dynamic>>> getOrders({
    int page = 1,
    int perPage = 32,
  }) async {
    return ApiX.get<Map<String, dynamic>>(
      '/orders?page=$page&per_page=$perPage',
      requiresAuth: true,
    );
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
    return ApiX.get<Map<String, dynamic>>(
      '/orders/$orderId',
      requiresAuth: true,
      fromJson: (data) => data as Map<String, dynamic>,
    );
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
    return ApiX.get<List<Map<String, dynamic>>>(
      '/orders/$orderId/payments',
      requiresAuth: true,
      fromJson: (data) =>
          (data as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }
}

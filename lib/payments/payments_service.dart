import '../shared/api_models.dart';
import '../shared/config/api_config.dart';
import '../shared/utils/api_x.dart';

/// Service untuk operasi payments (Create, List, Get by ID).
/// Memerlukan JWT token untuk authentication.
class PaymentsService {
  /// Create payment for an order
  ///
  /// Parameters:
  /// - orderId: ID of order to pay
  /// - amount: Payment amount (must be >= order total)
  /// - paymentMethod: Method of payment (cash, debit, credit, transfer, etc)
  /// - notes: Optional payment notes
  ///
  /// Returns:
  /// - Map<String, dynamic> berisi payment details
  ///
  /// Note:
  /// - Payment amount must be equal to or greater than order total
  /// - Updates order status to 'completed'
  /// - Cannot pay cancelled or already completed orders
  ///
  /// Example:
  /// ```dart
  /// final result = await PaymentsService.createPayment(
  ///   orderId: 3,
  ///   amount: 85000,
  ///   paymentMethod: 'cash',
  ///   notes: 'Cash payment',
  /// );
  /// ```
  static Future<ApiResponse<Map<String, dynamic>>> createPayment({
    required int orderId,
    required double amount,
    required String paymentMethod,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'order_id': orderId,
      'amount': amount,
      'payment_method': paymentMethod,
    };
    if (notes != null && notes.isNotEmpty) {
      body['notes'] = notes;
    }

    return ApiX.post<Map<String, dynamic>>(
      ApiConfig.payments,
      body: body,
      requiresAuth: true,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// Get list of all payments for authenticated tenant and branch
  ///
  /// Parameters:
  /// - page: Page number (default: 1)
  /// - perPage: Items per page (default: 32, max: 100)
  ///
  /// Returns:
  /// - Map<String, dynamic> berisi:
  ///   - data: List<Map<String, dynamic>> semua payments
  ///   - pagination: Map berisi page, per_page, total, total_pages
  ///
  /// Example:
  /// ```dart
  /// final result = await PaymentsService.getPayments(page: 1, perPage: 32);
  /// ```
  static Future<ApiResponse<Map<String, dynamic>>> getPayments({
    int page = 1,
    int perPage = 32,
  }) async {
    return ApiX.get<Map<String, dynamic>>(
      '${ApiConfig.payments}?page=$page&per_page=$perPage',
      requiresAuth: true,
    );
  }

  /// Get payment details by ID
  ///
  /// Parameters:
  /// - paymentId: ID of the payment
  ///
  /// Returns:
  /// - Map<String, dynamic> berisi detail payment
  ///
  /// Example:
  /// ```dart
  /// final result = await PaymentsService.getPaymentById(1);
  /// ```
  static Future<ApiResponse<Map<String, dynamic>>> getPaymentById(
    int paymentId,
  ) async {
    return ApiX.get<Map<String, dynamic>>(
      '${ApiConfig.payments}/$paymentId',
      requiresAuth: true,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
}

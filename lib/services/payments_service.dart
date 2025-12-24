import 'dart:convert';

import '../config/api_config.dart';
import '../models/api_models.dart';
import '../utils/http_client.dart';

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
    try {
      final body = <String, dynamic>{
        'order_id': orderId,
        'amount': amount,
        'payment_method': paymentMethod,
      };
      if (notes != null && notes.isNotEmpty) {
        body['notes'] = notes;
      }

      final response = await HttpClient().post(
        ApiConfig.payments,
        body: body,
        requiresAuth: true,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          data: data['data'] as Map<String, dynamic>,
          message: data['message'] ?? 'Payment created successfully',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          error: errorData['error'] ?? 'Failed to create payment',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        error: 'Error creating payment: $e',
      );
    }
  }

  /// Get list of all payments for authenticated tenant and branch
  ///
  /// Returns:
  /// - List<Map<String, dynamic>> berisi semua payments
  ///
  /// Example:
  /// ```dart
  /// final result = await PaymentsService.getPayments();
  /// ```
  static Future<ApiResponse<List<Map<String, dynamic>>>> getPayments() async {
    try {
      final response = await HttpClient().get(
        ApiConfig.payments,
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
    try {
      final response = await HttpClient().get(
        '${ApiConfig.payments}/$paymentId',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          data: data['data'] as Map<String, dynamic>,
          message: data['message'] ?? 'Payment retrieved successfully',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          error: errorData['error'] ?? 'Failed to get payment',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        error: 'Error getting payment: $e',
      );
    }
  }
}

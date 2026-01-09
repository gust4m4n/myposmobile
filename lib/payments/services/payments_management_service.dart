import '../../shared/utils/logger_x.dart';
import '../services/payment_offline_service.dart';
import 'payments_service.dart';

class PaymentsManagementService {
  final PaymentOfflineService _offlineService = PaymentOfflineService();

  /// Sync payments from server with large pagination
  Future<void> syncPaymentsFromServer() async {
    try {
      LoggerX.log(
        '💳 Syncing payments from server (page=1, pageSize=999999)...',
      );

      // Get payments from API with large pagination
      final response = await PaymentsService.getPayments(
        page: 1,
        perPage: 999999,
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        List<dynamic>? payments;

        // Try to extract payments list from response
        if (data.containsKey('items')) {
          // Response format: {"data": {"items": [...], "pagination": {...}}}
          payments = data['items'] as List<dynamic>?;
        } else if (data.containsKey('data') && data['data'] is List) {
          payments = data['data'] as List<dynamic>?;
        }

        if (payments != null && payments.isNotEmpty) {
          LoggerX.log('💳 Received ${payments.length} payments from API');

          // Convert to list of maps and save to local DB
          final paymentsList = payments
              .map((payment) => payment as Map<String, dynamic>)
              .toList();

          await _offlineService.savePayments(paymentsList);
          LoggerX.log(
            '✅ Successfully saved ${paymentsList.length} payments to local DB',
          );
        } else {
          LoggerX.log('ℹ️  No payments received from API');
        }
      } else {
        LoggerX.log('⚠️  Failed to fetch payments: ${response.message}');
      }
    } catch (e, stackTrace) {
      LoggerX.log('❌ Error syncing payments: $e');
      LoggerX.log('Stack trace: $stackTrace');
      rethrow;
    }
  }
}

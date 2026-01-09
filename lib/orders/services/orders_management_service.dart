import '../../shared/utils/logger_x.dart';
import '../services/order_offline_service.dart';
import 'orders_service.dart';

class OrdersManagementService {
  final OrderOfflineService _offlineService = OrderOfflineService();

  /// Sync orders from server with large pagination
  Future<void> syncOrdersFromServer() async {
    try {
      LoggerX.log('📋 Syncing orders from server (page=1, pageSize=999999)...');

      // Get orders from API with large pagination
      final response = await OrdersService.getOrders(page: 1, perPage: 999999);

      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        List<dynamic>? orders;

        // Try to extract orders list from response
        if (data.containsKey('items')) {
          // Response format: {"data": {"items": [...], "pagination": {...}}}
          orders = data['items'] as List<dynamic>?;
        } else if (data.containsKey('data') && data['data'] is List) {
          orders = data['data'] as List<dynamic>?;
        }

        if (orders != null && orders.isNotEmpty) {
          LoggerX.log('📋 Received ${orders.length} orders from API');

          // Convert to list of maps and save to local DB
          final ordersList = orders
              .map((order) => order as Map<String, dynamic>)
              .toList();

          await _offlineService.saveOrders(ordersList);
          LoggerX.log(
            '✅ Successfully saved ${ordersList.length} orders to local DB',
          );
        } else {
          LoggerX.log('ℹ️  No orders received from API');
        }
      } else {
        LoggerX.log('⚠️  Failed to fetch orders: ${response.message}');
      }
    } catch (e, stackTrace) {
      LoggerX.log('❌ Error syncing orders: $e');
      LoggerX.log('Stack trace: $stackTrace');
      rethrow;
    }
  }
}

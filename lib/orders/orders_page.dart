import 'package:flutter/material.dart';

import '../shared/utils/currency_formatter.dart';
import '../shared/widgets/app_bar_x.dart';
import '../shared/widgets/data_table_x.dart';
import '../translations/translation_extension.dart';
import 'order_detail_dialog.dart';
import 'orders_service.dart';

class OrdersPage extends StatefulWidget {
  final String languageCode;

  const OrdersPage({super.key, required this.languageCode});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    final response = await OrdersService.getOrders();

    if (!mounted) return;

    if (response.statusCode == 200 && response.data != null) {
      final data = (response.data as Map<String, dynamic>)['data'];
      if (data is List) {
        setState(() {
          _orders = data.cast<Map<String, dynamic>>();
        });
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showOrderDetail(Map<String, dynamic> order) async {
    final orderId = order['id'];
    if (orderId == null) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final response = await OrdersService.getOrderById(orderId);

    if (!mounted) return;

    // Close loading dialog
    Navigator.pop(context);

    if (response.statusCode == 200 && response.data != null) {
      // Show order detail dialog with fetched data
      showDialog(
        context: context,
        builder: (context) => OrderDetailDialog(
          order: response.data!,
          languageCode: widget.languageCode,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    TranslationService.setLanguage(widget.languageCode);

    return Scaffold(
      appBar: AppBarX(
        title: 'orders'.tr,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadOrders),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'noOrders'.tr,
                    style: const TextStyle(color: Colors.grey, fontSize: 16.0),
                  ),
                ],
              ),
            )
          : DataTableX(
              maxHeight: double.infinity,
              columnSpacing: 20,
              columns: [
                DataTableColumn.buildColumn(
                  context: context,
                  label: 'orderNumber'.tr,
                ),
                DataTableColumn.buildColumn(
                  context: context,
                  label: 'totalAmount'.tr,
                  numeric: true,
                ),
                DataTableColumn.buildColumn(
                  context: context,
                  label: 'status'.tr,
                ),
                DataTableColumn.buildColumn(
                  context: context,
                  label: 'createdAt'.tr,
                ),
              ],
              rows: _orders.map((order) {
                final orderNumber = order['order_number'] ?? 'N/A';
                final totalAmount = order['total_amount'] ?? 0;
                final status = order['status'] ?? 'pending';
                final createdAt = order['created_at'] ?? '';

                return DataRow(
                  onSelectChanged: (_) => _showOrderDetail(order),
                  cells: [
                    DataCell(
                      Text(
                        orderNumber,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(
                      Text(
                        CurrencyFormatter.format(totalAmount.toDouble()),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor(status),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(createdAt, style: const TextStyle(fontSize: 16.0)),
                    ),
                  ],
                );
              }).toList(),
            ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

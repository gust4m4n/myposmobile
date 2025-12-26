import 'package:flutter/material.dart';

import '../shared/utils/currency_formatter.dart';
import '../shared/widgets/app_bar_x.dart';
import '../shared/widgets/scrollable_data_table.dart';
import '../translations/app_localizations.dart';
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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await OrdersService.getOrders();

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        setState(() {
          _orders = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.error ?? 'Failed to load orders';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error loading orders: $e';
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

    try {
      final response = await OrdersService.getOrderById(orderId);

      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      if (response.isSuccess && response.data != null) {
        // Show order detail dialog with fetched data
        showDialog(
          context: context,
          builder: (context) => OrderDetailDialog(
            order: response.data!,
            languageCode: widget.languageCode,
          ),
        );
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error ?? 'Failed to load order details'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading order details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(widget.languageCode);

    return Scaffold(
      appBar: AppBarX(
        title: localizations.orders,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadOrders),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadOrders,
                    icon: const Icon(Icons.refresh),
                    label: Text(localizations.retry),
                  ),
                ],
              ),
            )
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
                    localizations.noOrders,
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : ScrollableDataTable(
              maxHeight: double.infinity,
              columnSpacing: 20,
              columns: [
                DataTableColumn.buildColumn(
                  context: context,
                  label: 'Order Number',
                ),
                DataTableColumn.buildColumn(
                  context: context,
                  label: 'Total Amount',
                  numeric: true,
                ),
                DataTableColumn.buildColumn(context: context, label: 'Status'),
                DataTableColumn.buildColumn(
                  context: context,
                  label: 'Created At',
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
                        style: const TextStyle(fontWeight: FontWeight.w600),
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
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(createdAt, style: const TextStyle(fontSize: 12)),
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

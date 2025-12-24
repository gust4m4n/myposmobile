import 'package:flutter/material.dart';

import '../services/orders_service.dart';
import '../utils/app_localizations.dart';
import '../utils/currency_formatter.dart';

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
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(widget.languageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.orders),
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
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                final orderNumber = order['order_number'] ?? 'N/A';
                final totalAmount = order['total_amount'] ?? 0;
                final status = order['status'] ?? 'pending';
                final createdAt = order['created_at'] ?? '';
                final notes = order['notes'];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(status),
                      child: const Icon(
                        Icons.receipt_long,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      orderNumber,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(CurrencyFormatter.format(totalAmount.toDouble())),
                        Text('Status: $status'),
                        if (notes != null && notes.toString().isNotEmpty)
                          Text(
                            'Notes: $notes',
                            style: const TextStyle(fontSize: 12),
                          ),
                        Text(
                          createdAt,
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showOrderDetail(order),
                  ),
                );
              },
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

class OrderDetailDialog extends StatelessWidget {
  final Map<String, dynamic> order;
  final String languageCode;

  const OrderDetailDialog({
    super.key,
    required this.order,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(languageCode);
    final orderNumber = order['order_number'] ?? 'N/A';
    final totalAmount = order['total_amount'] ?? 0;
    final status = order['status'] ?? 'pending';
    final notes = order['notes'];
    final createdAt = order['created_at'] ?? '';
    final items = (order['order_items'] as List?) ?? [];

    return AlertDialog(
      title: Text('${localizations.orderDetails}: $orderNumber'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Status', status, theme),
              _buildInfoRow(
                'Total',
                CurrencyFormatter.format(totalAmount.toDouble()),
                theme,
              ),
              if (notes != null && notes.toString().isNotEmpty)
                _buildInfoRow('Notes', notes.toString(), theme),
              _buildInfoRow('Created', createdAt, theme),
              const SizedBox(height: 16),
              Text(
                localizations.orderItems,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ...items.map((item) {
                final productName = item['product_name'] ?? 'Unknown';
                final quantity = item['quantity'] ?? 0;
                final price = item['price'] ?? 0;
                final subtotal = item['subtotal'] ?? 0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(productName),
                    subtitle: Text(
                      '${localizations.price}: ${CurrencyFormatter.format(price.toDouble())}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'x$quantity',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(CurrencyFormatter.format(subtotal.toDouble())),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(localizations.close),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              scrollDirection: Axis.vertical,
              child: SizedBox(
                width: double.infinity,
                child: DataTable(
                  showCheckboxColumn: false,
                  headingRowColor: WidgetStateProperty.all(
                    theme.colorScheme.primary.withOpacity(0.1),
                  ),
                  dataRowColor: WidgetStateProperty.resolveWith<Color>((
                    Set<WidgetState> states,
                  ) {
                    final isDark = theme.brightness == Brightness.dark;
                    if (states.contains(WidgetState.selected)) {
                      return theme.colorScheme.primary.withOpacity(
                        isDark ? 0.3 : 0.2,
                      );
                    }
                    if (states.contains(WidgetState.hovered)) {
                      return theme.colorScheme.primary.withOpacity(
                        isDark ? 0.15 : 0.08,
                      );
                    }
                    return Colors.transparent;
                  }),
                  dataRowMinHeight: 60,
                  dataRowMaxHeight: 80,
                  columnSpacing: 20,
                  columns: [
                    DataColumn(
                      label: Text(
                        'Order Number',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Total Amount',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text(
                        'Status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Created At',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
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
              ),
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
              ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  scrollbars: false,
                  overscroll: false,
                  physics: const ClampingScrollPhysics(),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      theme.colorScheme.primary.withOpacity(0.1),
                    ),
                    columns: [
                      DataColumn(
                        label: Text(
                          'Product',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          localizations.price,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text(
                          'Qty',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text(
                          'Subtotal',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        numeric: true,
                      ),
                    ],
                    rows: items.map((item) {
                      final productName = item['product_name'] ?? 'Unknown';
                      final quantity = item['quantity'] ?? 0;
                      final price = item['price'] ?? 0;
                      final subtotal = item['subtotal'] ?? 0;

                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(CurrencyFormatter.format(price.toDouble())),
                          ),
                          DataCell(
                            Text(
                              '$quantity',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              CurrencyFormatter.format(subtotal.toDouble()),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
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

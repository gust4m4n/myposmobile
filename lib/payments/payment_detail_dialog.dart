import 'package:flutter/material.dart';

import '../orders/orders_service.dart';
import '../shared/utils/currency_formatter.dart';
import '../shared/widgets/dialog_x.dart';
import '../shared/widgets/scrollable_data_table.dart';
import '../translations/app_localizations.dart';

class PaymentDetailDialog extends StatefulWidget {
  final Map<String, dynamic> payment;
  final String languageCode;

  const PaymentDetailDialog({
    super.key,
    required this.payment,
    required this.languageCode,
  });

  @override
  State<PaymentDetailDialog> createState() => _PaymentDetailDialogState();
}

class _PaymentDetailDialogState extends State<PaymentDetailDialog> {
  Map<String, dynamic>? _orderData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
    });

    final orderId = widget.payment['order_id'];
    final response = await OrdersService.getOrderById(orderId);

    if (!mounted) return;

    if (response.isSuccess && response.data != null) {
      setState(() {
        _orderData = response.data!;
      });
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(widget.languageCode);
    final payment = widget.payment;
    final amount = payment['amount'] ?? 0;
    final paymentMethod = payment['payment_method'] ?? 'N/A';
    final status = payment['status'] ?? 'pending';
    final notes = payment['notes'];
    final createdAt = payment['created_at'] ?? '';
    final orderId = payment['order_id'] ?? 0;

    return DialogX(
      title: '${localizations.payments} #${payment['id'] ?? 'N/A'}',
      width: 500,
      onClose: () => Navigator.pop(context),
      content: SizedBox(
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoRow('Status', status, theme),
            _buildInfoRow(
              'Amount',
              CurrencyFormatter.format(amount.toDouble()),
              theme,
            ),
            _buildInfoRow(localizations.method, paymentMethod, theme),
            _buildInfoRow(localizations.orderId, '#$orderId', theme),
            if (notes != null && notes.toString().isNotEmpty)
              _buildInfoRow('Notes', notes.toString(), theme),
            _buildInfoRow('Created', createdAt, theme),
            const SizedBox(height: 16),
            Text(
              localizations.orderItems,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_orderData != null)
              Expanded(
                child: ScrollableDataTable(
                  maxHeight: double.infinity,
                  columnSpacing: 16,
                  columns: [
                    DataTableColumn.buildColumn(
                      context: context,
                      label: 'Product',
                    ),
                    DataTableColumn.buildColumn(
                      context: context,
                      label: localizations.price,
                      numeric: true,
                    ),
                    DataTableColumn.buildColumn(
                      context: context,
                      label: 'Qty',
                      numeric: true,
                    ),
                    DataTableColumn.buildColumn(
                      context: context,
                      label: 'Subtotal',
                      numeric: true,
                    ),
                  ],
                  rows: (_orderData!['order_items'] as List? ?? []).map((item) {
                    final productName = item['product_name'] ?? 'Unknown';
                    final quantity = item['quantity'] ?? 0;
                    final price = item['price'] ?? 0;
                    final subtotal = item['subtotal'] ?? 0;

                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            productName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        DataCell(
                          Text(CurrencyFormatter.format(price.toDouble())),
                        ),
                        DataCell(
                          Text(
                            '$quantity',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataCell(
                          Text(
                            CurrencyFormatter.format(subtotal.toDouble()),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
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

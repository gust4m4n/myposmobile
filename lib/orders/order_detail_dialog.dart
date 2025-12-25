import 'package:flutter/material.dart';

import '../shared/utils/app_localizations.dart';
import '../shared/utils/currency_formatter.dart';
import '../shared/widgets/scrollable_data_table.dart';

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
              ScrollableDataTable(
                maxHeight: 300,
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

import 'package:flutter/material.dart';

import '../shared/utils/currency_formatter.dart';
import '../shared/widgets/dialog_x.dart';
import '../shared/widgets/scrollable_data_table.dart';
import '../translations/translation_extension.dart';

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
    TranslationService.setLanguage(languageCode);
    final orderNumber = order['order_number'] ?? 'N/A';
    final totalAmount = order['total_amount'] ?? 0;
    final status = order['status'] ?? 'pending';
    final notes = order['notes'];
    final createdAt = order['created_at'] ?? '';
    final items = (order['order_items'] as List?) ?? [];

    return DialogX(
      title: '${'orderDetails'.tr}: $orderNumber',
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
              'Total',
              CurrencyFormatter.format(totalAmount.toDouble()),
              theme,
            ),
            if (notes != null && notes.toString().isNotEmpty)
              _buildInfoRow('Notes', notes.toString(), theme),
            _buildInfoRow('Created', createdAt, theme),
            const SizedBox(height: 16),
            Text(
              'orderItems'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ScrollableDataTable(
                maxHeight: double.infinity,
                columnSpacing: 16,
                columns: [
                  DataTableColumn.buildColumn(
                    context: context,
                    label: 'product'.tr,
                  ),
                  DataTableColumn.buildColumn(
                    context: context,
                    label: 'price'.tr,
                    numeric: true,
                  ),
                  DataTableColumn.buildColumn(
                    context: context,
                    label: 'qty'.tr,
                    numeric: true,
                  ),
                  DataTableColumn.buildColumn(
                    context: context,
                    label: 'subtotal'.tr,
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

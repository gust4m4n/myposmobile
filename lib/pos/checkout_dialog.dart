import 'package:flutter/material.dart';

import '../shared/utils/app_localizations.dart';
import '../shared/utils/currency_formatter.dart';
import '../shared/widgets/action_button.dart';
import '../shared/widgets/scrollable_data_table.dart';
import 'product_model.dart';

class CheckoutDialog extends StatelessWidget {
  final String languageCode;
  final List<CartItemModel> cart;
  final double totalPrice;
  final VoidCallback onCancel;
  final Future<void> Function(String paymentMethod) onProcessCheckout;

  const CheckoutDialog({
    super.key,
    required this.languageCode,
    required this.cart,
    required this.totalPrice,
    required this.onCancel,
    required this.onProcessCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(languageCode);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(localizations.checkoutTitle),
      content: SizedBox(
        width: 600,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // DataTable for cart items with scroll
            ScrollableDataTable(
              columns: [
                DataTableColumn.buildColumn(context: context, label: 'Product'),
                DataTableColumn.buildColumn(
                  context: context,
                  label: 'Qty',
                  numeric: true,
                ),
                DataTableColumn.buildColumn(
                  context: context,
                  label: localizations.price,
                  numeric: true,
                ),
                DataTableColumn.buildColumn(
                  context: context,
                  label: 'Subtotal',
                  numeric: true,
                ),
              ],
              rows: cart.map((cartItem) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        cartItem.product.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${cartItem.quantity}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(
                      Text(CurrencyFormatter.format(cartItem.product.price)),
                    ),
                    DataCell(
                      Text(
                        CurrencyFormatter.format(cartItem.total),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Total
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localizations.total,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(totalPrice),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        ActionButton(
          onPressed: onCancel,
          icon: Icons.close,
          label: localizations.cancel,
          backgroundColor: Colors.red.shade600,
        ),
        ActionButton(
          onPressed: () async {
            await onProcessCheckout('cash');
            Navigator.pop(context);
          },
          icon: Icons.money,
          label: 'Tunai',
          backgroundColor: Colors.green.shade600,
        ),
        ActionButton(
          onPressed: () async {
            await onProcessCheckout('card');
            Navigator.pop(context);
          },
          icon: Icons.credit_card,
          label: 'Kartu',
          backgroundColor: Colors.blue.shade600,
        ),
        ActionButton(
          onPressed: () async {
            await onProcessCheckout('transfer');
            Navigator.pop(context);
          },
          icon: Icons.account_balance,
          label: 'Transfer',
          backgroundColor: Colors.orange.shade600,
        ),
        ActionButton(
          onPressed: () async {
            await onProcessCheckout('qris');
            Navigator.pop(context);
          },
          icon: Icons.qr_code,
          label: 'QRIS',
          backgroundColor: theme.colorScheme.primary,
        ),
      ],
    );
  }
}

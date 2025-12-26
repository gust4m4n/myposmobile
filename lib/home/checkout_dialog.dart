import 'package:flutter/material.dart';
import 'package:myposmobile/shared/widgets/button_x.dart';

import '../shared/utils/currency_formatter.dart';
import '../shared/widgets/dialog_x.dart';
import '../shared/widgets/scrollable_data_table.dart';
import '../translations/translation_extension.dart';
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
    TranslationService.setLanguage(languageCode);

    return DialogX(
      title: 'checkoutTitle'.tr,
      onClose: onCancel,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // DataTable for cart items with scroll
          ScrollableDataTable(
            columns: [
              DataTableColumn.buildColumn(
                context: context,
                label: 'product'.tr,
              ),
              DataTableColumn.buildColumn(
                context: context,
                label: 'qty'.tr,
                numeric: true,
              ),
              DataTableColumn.buildColumn(
                context: context,
                label: 'price'.tr,
                numeric: true,
              ),
              DataTableColumn.buildColumn(
                context: context,
                label: 'subtotal'.tr,
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
                  'total'.tr,
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
      actions: [
        ButtonX(
          onPressed: () async {
            await onProcessCheckout('cash');
            Navigator.pop(context);
          },
          icon: Icons.money,
          label: 'cash'.tr,
          backgroundColor: const Color(0xFF34C759),
        ),
        ButtonX(
          onPressed: () async {
            await onProcessCheckout('card');
            Navigator.pop(context);
          },
          icon: Icons.credit_card,
          label: 'card'.tr,
          backgroundColor: const Color(0xFF007AFF),
        ),
        ButtonX(
          onPressed: () async {
            await onProcessCheckout('transfer');
            Navigator.pop(context);
          },
          icon: Icons.account_balance,
          label: 'Transfer',
          backgroundColor: const Color(0xFFFF9500),
        ),
        ButtonX(
          onPressed: () async {
            await onProcessCheckout('qris');
            Navigator.pop(context);
          },
          icon: Icons.qr_code,
          label: 'QRIS',
          backgroundColor: const Color(0xFF5856D6),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:myposmobile/shared/widgets/button_x.dart';

import '../../shared/utils/currency_formatter.dart';
import '../../shared/widgets/data_table_x.dart';
import '../../shared/widgets/dialog_x.dart';
import '../../translations/translation_extension.dart';
import '../models/product_model.dart';

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
          DataTableX(
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
                      style: const TextStyle(fontWeight: FontWeight.normal),
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'total'.tr,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(totalPrice),
                  style: TextStyle(
                    fontSize: 16.0,
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
          onClicked: () async {
            Navigator.pop(context);
            await onProcessCheckout('cash');
          },
          label: 'cash'.tr,
          backgroundColor: const Color(0xFF34C759),
        ),
        ButtonX(
          onClicked: () async {
            Navigator.pop(context);
            await onProcessCheckout('card');
          },
          label: 'card'.tr,
          backgroundColor: const Color(0xFF007AFF),
        ),
        ButtonX(
          onClicked: () async {
            Navigator.pop(context);
            await onProcessCheckout('transfer');
          },
          label: 'Transfer',
          backgroundColor: const Color(0xFFFF9500),
        ),
        ButtonX(
          onClicked: () async {
            Navigator.pop(context);
            await onProcessCheckout('qris');
          },
          label: 'QRIS',
          backgroundColor: const Color(0xFF5856D6),
        ),
      ],
    );
  }
}

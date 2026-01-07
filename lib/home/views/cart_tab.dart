import 'package:flutter/material.dart';

import '../../shared/utils/currency_formatter.dart';
import '../../shared/widgets/button_x.dart';
import '../../translations/translation_extension.dart';
import '../models/product_model.dart';

class CartTab extends StatelessWidget {
  final List<CartItemModel> cart;
  final String languageCode;
  final VoidCallback onCheckout;
  final Function(int) onRemoveFromCart;

  const CartTab({
    super.key,
    required this.cart,
    required this.languageCode,
    required this.onCheckout,
    required this.onRemoveFromCart,
  });

  double get _totalPrice {
    return cart.fold(0, (sum, item) => sum + item.total);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    TranslationService.setLanguage(languageCode);

    return Column(
      children: [
        Expanded(
          child: cart.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 80,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'emptyCart'.tr,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(8),
                  itemCount: cart.length,
                  itemBuilder: (context, index) {
                    final item = cart[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          item.product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: CurrencyFormatter.format(
                                    item.product.price,
                                  ),
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: ' x ',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 14.0,
                                  ),
                                ),
                                TextSpan(
                                  text: '${item.quantity}',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              CurrencyFormatter.format(item.total),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              color: theme.colorScheme.error,
                              onPressed: () => onRemoveFromCart(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        if (cart.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(
                top: BorderSide(color: theme.dividerColor, width: 1),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'total'.tr,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(_totalPrice),
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ButtonX(
                    onClicked: onCheckout,
                    label: 'checkout'.tr,
                    backgroundColor: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

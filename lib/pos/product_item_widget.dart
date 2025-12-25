import 'package:flutter/material.dart';

import '../shared/utils/currency_formatter.dart';
import 'product_model.dart';

class ProductItemWidget extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final double iconSize;
  final double fontSize;
  final double priceSize;
  final double padding;

  const ProductItemWidget({
    super.key,
    required this.product,
    required this.onTap,
    this.iconSize = 36,
    this.fontSize = 13,
    this.priceSize = 12,
    this.padding = 12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(color: theme.dividerColor, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  flex: 2,
                  child: Icon(
                    product.category == 'Makanan'
                        ? Icons.restaurant
                        : Icons.local_drink,
                    size: iconSize,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(height: padding / 2),
                Flexible(
                  flex: 2,
                  child: Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: padding / 3),
                Flexible(
                  flex: 1,
                  child: Text(
                    CurrencyFormatter.format(product.price),
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: priceSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

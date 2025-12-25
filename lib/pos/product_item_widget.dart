import 'package:flutter/material.dart';

import '../shared/utils/currency_formatter.dart';
import 'product_model.dart';

class ProductItemWidget extends StatefulWidget {
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
  State<ProductItemWidget> createState() => _ProductItemWidgetState();
}

class _ProductItemWidgetState extends State<ProductItemWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        decoration: BoxDecoration(
          color: _isPressed
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.cardColor,
          border: Border.all(
            color: _isPressed ? theme.colorScheme.primary : theme.dividerColor,
            width: _isPressed ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(widget.padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex: 2,
                child: Icon(
                  widget.product.category == 'Makanan'
                      ? Icons.restaurant
                      : Icons.local_drink,
                  size: widget.iconSize,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: widget.padding / 2),
              Flexible(
                flex: 2,
                child: Text(
                  widget.product.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: widget.fontSize,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: widget.padding / 3),
              Flexible(
                flex: 1,
                child: Text(
                  CurrencyFormatter.format(widget.product.price),
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                    fontSize: widget.priceSize,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

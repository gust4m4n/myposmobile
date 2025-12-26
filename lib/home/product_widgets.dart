import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../shared/utils/currency_formatter.dart';
import 'product_model.dart';

/// Combined widget untuk menampilkan daftar produk dengan category filter dan grid
class ProductsWidget extends StatelessWidget {
  final List<ProductModel> products;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final Function(ProductModel) onProductTap;
  final bool isMobile;
  final List<String> categories;

  const ProductsWidget({
    super.key,
    required this.products,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onProductTap,
    this.isMobile = false,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CategoryFilter(
          selectedCategory: selectedCategory,
          onCategorySelected: onCategorySelected,
          isMobile: isMobile,
          categories: categories,
        ),
        Expanded(
          child: _ProductGrid(
            products: products,
            onProductTap: onProductTap,
            isMobile: isMobile,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Private: Category Filter
// ============================================================================

class _CategoryFilter extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final List<String> categories;
  final bool isMobile;

  const _CategoryFilter({
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.categories,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: isMobile ? 60 : 70,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false,
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
          },
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategory == category;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onCategorySelected(category),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary.withOpacity(0.5),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// Private: Product Grid
// ============================================================================

class _ProductGrid extends StatelessWidget {
  final List<ProductModel> products;
  final Function(ProductModel) onProductTap;
  final bool isMobile;

  const _ProductGrid({
    required this.products,
    required this.onProductTap,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxExtent;
        double iconSize;
        double fontSize;
        double priceSize;
        double padding;

        if (isMobile) {
          maxExtent = 160;
          if (constraints.maxWidth < 400) {
            maxExtent = constraints.maxWidth / 2 - 24;
          }
          iconSize = 32;
          fontSize = 16.0;
          priceSize = 16.0;
          padding = 8;
        } else {
          maxExtent = 180;
          if (constraints.maxWidth < 500) {
            maxExtent = 120;
          } else if (constraints.maxWidth < 700) {
            maxExtent = 150;
          }
          iconSize = 36;
          fontSize = 16.0;
          priceSize = 16.0;
          padding = 12;
        }

        return GridView.builder(
          padding: EdgeInsets.zero,
          physics: const ClampingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxExtent,
            childAspectRatio: 0.85,
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _ProductItem(
              product: product,
              onTap: () => onProductTap(product),
              iconSize: iconSize,
              fontSize: fontSize,
              priceSize: priceSize,
              padding: padding,
            );
          },
        );
      },
    );
  }
}

// ============================================================================
// Private: Product Item
// ============================================================================

class _ProductItem extends StatefulWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final double iconSize;
  final double fontSize;
  final double priceSize;
  final double padding;

  const _ProductItem({
    required this.product,
    required this.onTap,
    this.iconSize = 36,
    this.fontSize = 16.0,
    this.priceSize = 16.0,
    this.padding = 12,
  });

  @override
  State<_ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<_ProductItem> {
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
                    fontWeight: FontWeight.bold,
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
                    fontWeight: FontWeight.bold,
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

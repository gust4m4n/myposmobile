import 'package:flutter/material.dart';

import 'product_item_widget.dart';
import 'product_model.dart';

class ProductGridWidget extends StatelessWidget {
  final List<ProductModel> products;
  final Function(ProductModel) onProductTap;
  final bool isMobile;

  const ProductGridWidget({
    super.key,
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
          fontSize = 12;
          priceSize = 11;
          padding = 8;
        } else {
          maxExtent = 180;
          if (constraints.maxWidth < 500) {
            maxExtent = 120;
          } else if (constraints.maxWidth < 700) {
            maxExtent = 150;
          }
          iconSize = 36;
          fontSize = 13;
          priceSize = 12;
          padding = 12;
        }

        return GridView.builder(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          physics: const ClampingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxExtent,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductItemWidget(
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

import 'package:flutter/material.dart';

import '../models/product_model.dart';
import 'category_filter_widget.dart';
import 'product_grid_widget.dart';

class ProductSectionWidget extends StatelessWidget {
  final List<ProductModel> products;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final Function(ProductModel) onProductTap;
  final bool isMobile;
  final List<String> categories;

  const ProductSectionWidget({
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
        CategoryFilterWidget(
          selectedCategory: selectedCategory,
          onCategorySelected: onCategorySelected,
          isMobile: isMobile,
          categories: categories,
        ),
        Expanded(
          child: ProductGridWidget(
            products: products,
            onProductTap: onProductTap,
            isMobile: isMobile,
          ),
        ),
      ],
    );
  }
}

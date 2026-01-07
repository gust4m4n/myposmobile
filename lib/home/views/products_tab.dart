import 'package:flutter/material.dart';

import '../models/product_model.dart';
import 'product_widgets.dart';

class ProductsTab extends StatefulWidget {
  final List<ProductModel> products;
  final String initialCategory;
  final List<String> categories;
  final Function(String) onCategorySelected;
  final Function(ProductModel) onProductTap;
  final ScrollController scrollController;
  final bool isLoadingMore;

  const ProductsTab({
    super.key,
    required this.products,
    required this.initialCategory,
    required this.categories,
    required this.onCategorySelected,
    required this.onProductTap,
    required this.scrollController,
    required this.isLoadingMore,
  });

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return ProductsWidget(
      key: const ValueKey('products_widget'),
      onProductTap: widget.onProductTap,
      isMobile: true,
    );
  }
}

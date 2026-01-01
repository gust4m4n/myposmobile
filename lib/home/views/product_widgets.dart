import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../shared/config/api_config.dart';
import '../../shared/utils/currency_formatter.dart';
import '../../shared/widgets/search_field.dart';
import '../models/product_model.dart';

/// Combined widget untuk menampilkan daftar produk dengan category filter dan grid
class ProductsWidget extends StatefulWidget {
  final List<ProductModel> products;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final Function(ProductModel) onProductTap;
  final bool isMobile;
  final List<String> categories;
  final ScrollController? scrollController;
  final VoidCallback? onLoadMore;
  final bool? isLoadingMore;
  final bool? hasMoreData;

  const ProductsWidget({
    super.key,
    required this.products,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onProductTap,
    this.isMobile = false,
    required this.categories,
    this.scrollController,
    this.onLoadMore,
    this.isLoadingMore,
    this.hasMoreData,
  });

  @override
  State<ProductsWidget> createState() => _ProductsWidgetState();
}

class _ProductsWidgetState extends State<ProductsWidget> {
  String _searchQuery = '';

  List<ProductModel> get _filteredProducts {
    List<ProductModel> filtered;
    if (_searchQuery.isEmpty) {
      filtered = widget.products;
    } else {
      filtered = widget.products.where((product) {
        return product.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Sort by name
    filtered.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CategoryFilter(
          selectedCategory: widget.selectedCategory,
          onCategorySelected: widget.onCategorySelected,
          isMobile: widget.isMobile,
          categories: widget.categories,
          onSearchChanged: (query) {
            setState(() {
              _searchQuery = query;
            });
          },
        ),
        Expanded(
          child: _ProductGrid(
            products: _filteredProducts,
            onProductTap: widget.onProductTap,
            isMobile: widget.isMobile,
            scrollController: widget.scrollController,
            onLoadMore: widget.onLoadMore,
            isLoadingMore: widget.isLoadingMore ?? false,
            hasMoreData: widget.hasMoreData ?? false,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Private: Category Filter
// ============================================================================

class _CategoryFilter extends StatefulWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final List<String> categories;
  final bool isMobile;
  final ValueChanged<String> onSearchChanged;

  const _CategoryFilter({
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.categories,
    this.isMobile = false,
    required this.onSearchChanged,
  });

  @override
  State<_CategoryFilter> createState() => _CategoryFilterState();
}

class _CategoryFilterState extends State<_CategoryFilter> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: widget.isMobile ? 60 : 70,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
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
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isMobile ? 12 : 16,
                ),
                itemCount: widget.categories.length,
                itemBuilder: (context, index) {
                  final category = widget.categories[index];
                  final isSelected = widget.selectedCategory == category;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => widget.onCategorySelected(category),
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
          ),
          const SizedBox(width: 12),
          Padding(
            padding: EdgeInsets.only(right: widget.isMobile ? 12 : 16),
            child: SearchField(
              controller: _searchController,
              onChanged: (value) {
                widget.onSearchChanged(value);
                setState(() {});
              },
              width: 168,
            ),
          ),
        ],
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
  final ScrollController? scrollController;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final bool hasMoreData;

  const _ProductGrid({
    required this.products,
    required this.onProductTap,
    this.isMobile = false,
    this.scrollController,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMoreData = false,
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

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (onLoadMore != null &&
                scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 200) {
              if (!isLoadingMore && hasMoreData) {
                onLoadMore!();
              }
            }
            return false;
          },
          child: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
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
                      onClicked: () => onProductTap(product),
                      iconSize: iconSize,
                      fontSize: fontSize,
                      priceSize: priceSize,
                      padding: padding,
                    );
                  },
                ),
              ),
              if (isLoadingMore)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
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
  final VoidCallback onClicked;
  final double iconSize;
  final double fontSize;
  final double priceSize;
  final double padding;

  const _ProductItem({
    required this.product,
    required this.onClicked,
    this.iconSize = 36,
    this.fontSize = 16.0,
    this.priceSize = 16.0,
    this.padding = 12,
  });

  @override
  State<_ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<_ProductItem> {
  bool _isClicked = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isClicked = true),
      onTapUp: (_) => setState(() => _isClicked = false),
      onTapCancel: () => setState(() => _isClicked = false),
      onTap: widget.onClicked,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..scale(_isClicked ? 0.95 : 1.0),
        decoration: BoxDecoration(
          color: _isClicked
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.cardColor,
          border: Border.all(
            color: _isClicked ? theme.colorScheme.primary : theme.dividerColor,
            width: _isClicked ? 2 : 1,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final imageHeight = constraints.maxHeight * 0.5;

            return SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: imageHeight,
                    width: double.infinity,
                    child:
                        widget.product.image != null &&
                            widget.product.image!.isNotEmpty
                        ? Image.network(
                            '${ApiConfig.baseUrl}${widget.product.image}',
                            width: double.infinity,
                            height: imageHeight,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: imageHeight,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.1,
                                  ),
                                ),
                                child: Icon(
                                  widget.product.category == 'Makanan'
                                      ? Icons.restaurant
                                      : Icons.local_drink,
                                  size: widget.iconSize,
                                  color: theme.colorScheme.primary,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: double.infinity,
                                height: imageHeight,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.1,
                                  ),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            width: double.infinity,
                            height: imageHeight,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                            ),
                            child: Icon(
                              widget.product.category == 'Makanan'
                                  ? Icons.restaurant
                                  : Icons.local_drink,
                              size: widget.iconSize,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: widget.padding),
                    child: Column(
                      children: [
                        Text(
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
                        SizedBox(height: widget.padding / 3),
                        Text(
                          CurrencyFormatter.format(widget.product.price),
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: widget.priceSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

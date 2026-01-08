import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../categories/services/categories_management_service.dart';
import '../../shared/config/api_config.dart';
import '../../shared/utils/currency_formatter.dart';
import '../../shared/widgets/search_field_x.dart';
import '../models/product_model.dart';
import '../services/products_service.dart';

/// Independent widget untuk menampilkan daftar produk dengan category filter dan grid
/// Load data sendiri dari API
class ProductsWidget extends StatefulWidget {
  final Function(ProductModel) onProductTap;
  final bool isMobile;

  const ProductsWidget({
    super.key,
    required this.onProductTap,
    this.isMobile = false,
  });

  @override
  State<ProductsWidget> createState() => _ProductsWidgetState();
}

class _ProductsWidgetState extends State<ProductsWidget> {
  String _searchQuery = '';
  int? _selectedCategoryId; // null means 'All'
  List<ProductModel> _products = [];
  Map<int, String> _categories = {}; // id -> name mapping
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  final int _pageSize = 32;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadAllCategories();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreProducts();
      }
    }
  }

  Future<void> _loadAllCategories() async {
    final service = CategoriesManagementService();
    final response = await service.getCategories(
      pageSize: 1000,
      activeOnly: true,
    );

    if (!mounted) return;

    if (response.statusCode == 200 && response.data != null) {
      final allCategories = response.data!.data;
      if (mounted) {
        setState(() {
          _categories = {
            for (var cat in allCategories)
              if (cat.id != null) cat.id!: cat.name,
          };
        });
      }
    }
  }

  Future<void> _loadProducts() async {
    _isLoading = true;
    _currentPage = 1;
    _hasMoreData = true;

    final response = _selectedCategoryId == null
        ? await ProductsService.getProducts(
            page: _currentPage,
            pageSize: _pageSize,
          )
        : await ProductsService.getProductsByCategory(
            categoryId: _selectedCategoryId!,
            page: _currentPage,
            pageSize: _pageSize,
          );

    if (!mounted) return;

    if (response.statusCode == 200 && response.data != null) {
      setState(() {
        _products = response.data!.data
            .map((json) => ProductModel.fromJson(json))
            .toList();
        _hasMoreData = response.data!.page < response.data!.totalPages;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMoreData) return;

    // Set flag without setState to avoid build during frame
    _isLoadingMore = true;

    _currentPage++;
    final response = _selectedCategoryId == null
        ? await ProductsService.getProducts(
            page: _currentPage,
            pageSize: _pageSize,
          )
        : await ProductsService.getProductsByCategory(
            categoryId: _selectedCategoryId!,
            page: _currentPage,
            pageSize: _pageSize,
          );

    if (!mounted) return;

    if (response.statusCode == 200 && response.data != null) {
      final newProducts = response.data!.data
          .map((json) => ProductModel.fromJson(json))
          .toList();
      setState(() {
        _products.addAll(newProducts);
        _hasMoreData = response.data!.page < response.data!.totalPages;
        _isLoadingMore = false;
      });
    } else {
      setState(() {
        _isLoadingMore = false;
        _currentPage--;
      });
    }
  }

  void _handleCategorySelected(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
    _loadProducts();
  }

  List<ProductModel> get _filteredProducts {
    List<ProductModel> filtered;
    if (_searchQuery.isEmpty) {
      filtered = _products;
    } else {
      filtered = _products.where((product) {
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        RepaintBoundary(
          child: _SearchBar(
            controller: _searchController,
            isMobile: widget.isMobile,
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
          ),
        ),
        _CategoryBar(
          key: ValueKey('category_$_selectedCategoryId'),
          selectedCategoryId: _selectedCategoryId,
          onCategorySelected: _handleCategorySelected,
          isMobile: widget.isMobile,
          categories: _categories,
        ),
        Expanded(
          child: _ProductGrid(
            products: _filteredProducts,
            onProductTap: widget.onProductTap,
            isMobile: widget.isMobile,
            scrollController: _scrollController,
            onLoadMore: _loadMoreProducts,
            isLoadingMore: _isLoadingMore,
            hasMoreData: _hasMoreData,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Private: Search Bar
// ============================================================================

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isMobile;
  final ValueChanged<String> onSearchChanged;

  const _SearchBar({
    required this.controller,
    this.isMobile = false,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 12 : 16,
        10,
        isMobile ? 12 : 16,
        8,
      ),
      child: SearchFieldX(
        controller: controller,
        onChanged: onSearchChanged,
        width: double.infinity,
      ),
    );
  }
}

// ============================================================================
// Private: Category Bar
// ============================================================================

class _CategoryBar extends StatefulWidget {
  final int? selectedCategoryId;
  final ValueChanged<int?> onCategorySelected;
  final Map<int, String> categories;
  final bool isMobile;

  const _CategoryBar({
    super.key,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.categories,
    this.isMobile = false,
  });

  @override
  State<_CategoryBar> createState() => _CategoryBarState();
}

class _CategoryBarState extends State<_CategoryBar> {
  final ScrollController _categoryScrollController = ScrollController();

  @override
  void dispose() {
    _categoryScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: widget.isMobile ? 50 : 60,
      padding: const EdgeInsets.only(bottom: 10),
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
          key: const PageStorageKey('category_list'),
          controller: _categoryScrollController,
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 12 : 16),
          itemCount: widget.categories.length + 1, // +1 for 'All'
          itemBuilder: (context, index) {
            final bool isAll = index == 0;
            final int? categoryId = isAll
                ? null
                : widget.categories.keys.elementAt(index - 1);
            final String categoryName = isAll
                ? 'All'
                : widget.categories[categoryId]!;
            final isSelected = widget.selectedCategoryId == categoryId;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => widget.onCategorySelected(categoryId),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 4.0,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  child: Text(
                    categoryName,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.7),
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

  /// Helper function to get correct image URL
  /// Checks if URL is already full URL or needs baseUrl prepended
  String _getImageUrl(String imageUrl) {
    // Check if imageUrl is already a full URL (starts with http:// or https://)
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    // If it's a relative path, prepend baseUrl
    return '${ApiConfig.baseUrl}$imageUrl';
  }

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
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
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
                            _getImageUrl(widget.product.image!),
                            width: double.infinity,
                            height: imageHeight,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: imageHeight,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.1,
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
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.1,
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
                            decoration: BoxDecoration(color: Colors.grey[200]),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  size: widget.iconSize,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No Image',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
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

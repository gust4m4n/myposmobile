import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../categories/services/category_service.dart';
import '../../products/services/product_service.dart';
import '../../shared/config/api_config.dart';
import '../../shared/utils/currency_formatter.dart';
import '../../shared/widgets/search_field_x.dart';
import '../models/product_model.dart';

/// Independent widget untuk menampilkan daftar produk dengan category filter dan grid
/// Load data dari local database (offline-first) dengan auto-sync
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
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();

  @override
  void initState() {
    super.initState();
    _loadAllCategories();
    _loadProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Load categories from local database
  Future<void> _loadAllCategories() async {
    try {
      debugPrint('📁 Loading categories from database...');
      final categories = await _categoryService.getAllCategories();
      debugPrint('📁 Found ${categories.length} categories');
      if (!mounted) return;
      setState(() {
        _categories = {
          for (var cat in categories)
            if (cat.id != null) cat.id!: cat.name,
        };
      });
      debugPrint('📁 Categories map size: ${_categories.length}');
    } catch (e) {
      debugPrint('❌ Error loading categories: $e');
    }
  }

  // Load products from local database
  Future<void> _loadProducts() async {
    if (_isLoading) return;

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      List<ProductModel> results;

      if (_selectedCategoryId != null) {
        results = await _productService.getProductsByCategory(
          _selectedCategoryId!,
        );
      } else {
        results = await _productService.getAllProducts();
      }

      // Filter by search query if exists
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        results = results.where((p) {
          final name = p.name.toLowerCase();
          final description = (p.description ?? '').toLowerCase();
          final sku = (p.sku ?? '').toLowerCase();
          return name.contains(query) ||
              description.contains(query) ||
              sku.contains(query);
        }).toList();
        debugPrint('📦 After search filter: ${results.length} products');
      }

      if (!mounted) return;
      setState(() {
        _products = results;
        _isLoading = false;
      });
      debugPrint('✅ Products loaded: ${_products.length} products displayed');
    } catch (e) {
      debugPrint('❌ Error loading products: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onCategorySelected(int? categoryId) {
    if (!mounted) return;
    setState(() {
      _selectedCategoryId = categoryId;
    });
    _loadProducts();
  }

  void _onSearchChanged(String query) {
    if (!mounted) return;
    setState(() {
      _searchQuery = query;
    });
    _loadProducts();
  }

  List<ProductModel> get _filteredProducts {
    // Sort by name
    _products.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return _products;
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
            onSearchChanged: _onSearchChanged,
          ),
        ),
        _CategoryBar(
          key: ValueKey('category_$_selectedCategoryId'),
          selectedCategoryId: _selectedCategoryId,
          onCategorySelected: _onCategorySelected,
          isMobile: widget.isMobile,
          categories: _categories,
        ),
        Expanded(
          child: _ProductGrid(
            products: _filteredProducts,
            onProductTap: widget.onProductTap,
            isMobile: widget.isMobile,
            scrollController: _scrollController,
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

  const _ProductGrid({
    required this.products,
    required this.onProductTap,
    this.isMobile = false,
    this.scrollController,
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
                                  widget.product.categoryDetail?['name'] ==
                                          'Makanan'
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

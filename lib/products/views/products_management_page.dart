import 'package:flutter/material.dart';

import '../../home/models/product_model.dart';
import '../../home/services/products_service.dart';
import '../../home/views/product_widgets.dart';
import '../../shared/widgets/button_x.dart';
import '../../shared/widgets/dialog_x.dart';
import '../../shared/widgets/page_x.dart';
import '../../shared/widgets/toast_x.dart';
import '../../translations/translation_extension.dart';
import '../services/products_management_service.dart';
import 'add_product_dialog.dart';
import 'edit_product_dialog.dart';

class ProductsManagementPage extends StatefulWidget {
  final String languageCode;

  const ProductsManagementPage({super.key, required this.languageCode});

  @override
  State<ProductsManagementPage> createState() => _ProductsManagementPageState();
}

class _ProductsManagementPageState extends State<ProductsManagementPage> {
  List<ProductModel> _products = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  final int _pageSize = 32;

  @override
  void initState() {
    super.initState();
    TranslationService.setLanguage(widget.languageCode);
    _loadProducts();
    _loadAllCategories();
  }

  Future<void> _loadAllCategories() async {
    if (_categories.isNotEmpty) return;

    final response = await ProductsService.getProducts(page: 1, pageSize: 1000);

    if (!mounted) return;

    if (response.statusCode == 200 && response.data != null) {
      final allProducts = response.data!
          .map((json) => ProductModel.fromJson(json))
          .toList();
      _extractCategories(allProducts);
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMoreData = true;
    });

    final response = await ProductsService.getProducts(
      category: _selectedCategory == 'All' ? null : _selectedCategory,
      page: _currentPage,
      pageSize: _pageSize,
    );

    if (!mounted) return;

    if (response.statusCode == 200 && response.data != null) {
      setState(() {
        _products = response.data!
            .map((json) => ProductModel.fromJson(json))
            .toList();
        _hasMoreData = _products.length >= _pageSize;
      });
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    _currentPage++;
    final response = await ProductsService.getProducts(
      category: _selectedCategory == 'All' ? null : _selectedCategory,
      page: _currentPage,
      pageSize: _pageSize,
    );

    if (!mounted) return;

    if (response.statusCode == 200 && response.data != null) {
      final newProducts = response.data!
          .map((json) => ProductModel.fromJson(json))
          .toList();

      setState(() {
        _products.addAll(newProducts);
        _hasMoreData = newProducts.length >= _pageSize;
        _isLoadingMore = false;
      });
    } else {
      setState(() {
        _isLoadingMore = false;
        _currentPage--;
      });
    }
  }

  void _extractCategories(List<ProductModel> allProducts) {
    final categories = <String>{'All'};
    for (var product in allProducts) {
      if (product.category.isNotEmpty) {
        categories.add(product.category);
      }
    }
    setState(() {
      _categories = categories.toList();
    });
  }

  List<ProductModel> get _filteredProducts {
    if (_selectedCategory == 'All') {
      return _products;
    }
    return _products.where((p) => p.category == _selectedCategory).toList();
  }

  void _showAddProductDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddProductDialog(languageCode: widget.languageCode),
    );

    // Reload products if product was added successfully
    if (result == true) {
      _loadProducts();
    }
  }

  void _showEditProductDialog(ProductModel product) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditProductDialog(
        languageCode: widget.languageCode,
        product: product,
      ),
    );

    // Reload products if product was updated successfully
    if (result == true) {
      _loadProducts();
    }
  }

  void _showDeleteConfirmation(ProductModel product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => DialogX(
        title: 'deleteProduct'.tr,
        content: Text('${'deleteProductConfirmation'.tr}\n\n${product.name}'),
        actions: [
          ButtonX(
            onClicked: () => Navigator.pop(context, false),
            label: 'cancel'.tr,
            backgroundColor: Colors.grey,
          ),
          ButtonX(
            onClicked: () => Navigator.pop(context, true),
            label: 'delete'.tr,
            backgroundColor: Colors.red,
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Delete the product
    final response = await ProductsManagementService.deleteProduct(
      id: product.id!,
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      ToastX.success(context, 'productDeletedSuccess'.tr);
      _loadProducts();
    } else {
      ToastX.error(context, response.message ?? 'productDeletedFailed'.tr);
    }
  }

  void _showProductContextMenu(ProductModel product) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF007AFF)),
                title: Text('editProduct'.tr),
                onTap: () {
                  Navigator.pop(context);
                  _showEditProductDialog(product);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  'deleteProduct'.tr,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(product);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PageX(
      title: 'productsManagement'.tr,
      backgroundColor: theme.scaffoldBackgroundColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: SizedBox(
            width: 160,
            child: ButtonX(
              onClicked: () {
                // TODO: Navigate to category management
                ToastX.error(context, 'Category management coming soon');
              },
              label: 'Manage Categories',
              backgroundColor: const Color(0xFF007AFF),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: SizedBox(
            width: 160,
            child: ButtonX(
              onClicked: _showAddProductDialog,
              label: 'addProduct'.tr,
              backgroundColor: const Color(0xFF34C759),
            ),
          ),
        ),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ProductsWidget(
              products: _filteredProducts,
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                setState(() {
                  _selectedCategory = category;
                  _loadProducts();
                });
              },
              onProductTap: _showProductContextMenu,
              isMobile: false,
              categories: _categories,
              onLoadMore: _loadMoreProducts,
              isLoadingMore: _isLoadingMore,
              hasMoreData: _hasMoreData,
            ),
    );
  }
}

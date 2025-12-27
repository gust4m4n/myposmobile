import 'package:flutter/material.dart';

import '../home/product_model.dart';
import '../home/product_widgets.dart';
import '../home/products_service.dart';
import '../shared/widgets/app_bar_x.dart';
import '../shared/widgets/button_x.dart';
import '../translations/translation_extension.dart';
import 'add_product_dialog.dart';
import 'edit_product_dialog.dart';
import 'products_management_service.dart';

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

  @override
  void initState() {
    super.initState();
    TranslationService.setLanguage(widget.languageCode);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    final response = await ProductsService.getProducts();

    if (!mounted) return;

    if (response.statusCode == 200 && response.data != null) {
      setState(() {
        _products = response.data!
            .map((json) => ProductModel.fromJson(json))
            .toList();
        _extractCategories();
      });
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _extractCategories() {
    final categories = <String>{'All'};
    for (var product in _products) {
      if (product.category.isNotEmpty) {
        categories.add(product.category);
      }
    }
    _categories = categories.toList();
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
      builder: (context) => AlertDialog(
        title: Text('deleteProduct'.tr),
        content: Text('${'deleteProductConfirmation'.tr}\n\n${product.name}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('delete'.tr),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('productDeletedSuccess'.tr),
          backgroundColor: Colors.green,
        ),
      );
      _loadProducts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'productDeletedFailed'.tr),
          backgroundColor: Colors.red,
        ),
      );
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBarX(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(
              Icons.inventory_2,
              size: 24,
              color: theme.appBarTheme.foregroundColor,
            ),
            const SizedBox(width: 8),
            Text(
              'productsManagement'.tr,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SizedBox(
              width: 160,
              child: ButtonX(
                onPressed: _showAddProductDialog,
                icon: Icons.add,
                label: 'addProduct'.tr,
                backgroundColor: const Color(0xFF34C759),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ProductsWidget(
              products: _filteredProducts,
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              onProductTap: _showProductContextMenu,
              isMobile: false,
              categories: _categories,
            ),
    );
  }
}

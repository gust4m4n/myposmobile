import 'package:flutter/material.dart';

import '../home/product_model.dart';
import '../home/product_widgets.dart';
import '../home/products_service.dart';
import '../shared/widgets/app_bar_x.dart';
import '../shared/widgets/button_x.dart';
import '../translations/translation_extension.dart';
import 'add_product_dialog.dart';

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

  void _handleProductTap(ProductModel product) {
    // TODO: Implement edit product dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit: ${product.name}'),
        backgroundColor: Colors.blue,
      ),
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
              onProductTap: _handleProductTap,
              isMobile: false,
              categories: _categories,
            ),
    );
  }
}

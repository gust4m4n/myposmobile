import 'package:flutter/material.dart';

import '../../categories/views/categories_management_page.dart';
import '../../home/models/product_model.dart';
import '../../home/views/product_widgets.dart';
import '../../shared/widgets/page_x.dart';
import '../../translations/translation_extension.dart';
import 'add_product_dialog.dart';
import 'edit_product_dialog.dart';

class ProductsManagementPage extends StatefulWidget {
  final String languageCode;

  const ProductsManagementPage({super.key, required this.languageCode});

  @override
  State<ProductsManagementPage> createState() => _ProductsManagementPageState();
}

class _ProductsManagementPageState extends State<ProductsManagementPage> {
  @override
  void initState() {
    super.initState();
    TranslationService.setLanguage(widget.languageCode);
  }

  void _showAddProductDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddProductDialog(languageCode: widget.languageCode),
    );

    // Reload products if product was added successfully
    if (result == true) {
      // Force ProductsWidget to reload by updating key
      setState(() {});
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
      // Force ProductsWidget to reload by updating key
      setState(() {});
    }
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
        IconButton(
          icon: const Icon(Icons.category),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CategoriesManagementPage(languageCode: widget.languageCode),
              ),
            );
          },
          tooltip: 'Manage Categories',
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _showAddProductDialog,
          tooltip: 'addProduct'.tr,
        ),
      ],
      body: ProductsWidget(
        key: const ValueKey('products_management_widget'),
        onProductTap: _showEditProductDialog,
        isMobile: false,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../home/models/product_model.dart';
import '../../home/views/product_widgets.dart';
import '../../shared/widgets/button_x.dart';
import '../../shared/widgets/page_x.dart';
import '../../shared/widgets/toast_x.dart';
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
      body: ProductsWidget(
        key: const ValueKey('products_management_widget'),
        onProductTap: _showEditProductDialog,
        isMobile: false,
      ),
    );
  }
}

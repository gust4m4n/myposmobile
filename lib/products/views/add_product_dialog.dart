import 'package:flutter/material.dart';

import '../../shared/widgets/dialog_x.dart';
import '../../shared/widgets/gray_button_x.dart';
import '../../shared/widgets/green_button_x.dart';
import '../../shared/widgets/multiline_text_field_x.dart';
import '../../shared/widgets/text_field_x.dart';
import '../../shared/widgets/toast_x.dart';
import '../../translations/translation_extension.dart';
import '../services/products_management_service.dart';

class AddProductDialog extends StatefulWidget {
  final String languageCode;

  const AddProductDialog({super.key, required this.languageCode});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _skuController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  bool _isActive = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    TranslationService.setLanguage(widget.languageCode);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final response = await ProductsManagementService.createProduct(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _categoryController.text.trim(),
      sku: _skuController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      stock: int.parse(_stockController.text.trim()),
      isActive: _isActive,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (response.statusCode == 200) {
      ToastX.success(context, 'productCreatedSuccess'.tr);
      Navigator.of(context).pop(true); // Return true to indicate success
    } else {
      ToastX.error(context, response.message ?? 'productCreatedFailed'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DialogX(
      title: 'addProduct'.tr,
      width: 600,
      onClose: () => Navigator.of(context).pop(),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Name
              TextFieldX(
                controller: _nameController,
                hintText: 'productName'.tr,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'productNameRequired'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              MultilineTextFieldX(
                controller: _descriptionController,
                hintText: 'description'.tr,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'descriptionRequired'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category
              TextFieldX(
                controller: _categoryController,
                hintText: 'category'.tr,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'categoryRequired'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // SKU
              TextFieldX(
                controller: _skuController,
                hintText: 'sku'.tr,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'skuRequired'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Price and Stock
              Row(
                children: [
                  Expanded(
                    child: TextFieldX(
                      controller: _priceController,
                      hintText: 'price'.tr,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'priceRequired'.tr;
                        }
                        final price = double.tryParse(value);
                        if (price == null || price <= 0) {
                          return 'priceInvalid'.tr;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFieldX(
                      controller: _stockController,
                      hintText: 'stock'.tr,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'stockRequired'.tr;
                        }
                        final stock = int.tryParse(value);
                        if (stock == null || stock < 0) {
                          return 'stockInvalid'.tr;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Is Active
              SwitchListTile(
                title: Text('isActive'.tr),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
                tileColor: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: theme.dividerColor),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Expanded(
          child: GrayButtonX(
            onClicked: _isSubmitting ? null : () => Navigator.of(context).pop(),
            title: 'cancel'.tr,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GreenButtonX(
            onClicked: _isSubmitting ? null : _handleSubmit,
            title: _isSubmitting ? 'saving'.tr : 'save'.tr,
          ),
        ),
      ],
    );
  }
}

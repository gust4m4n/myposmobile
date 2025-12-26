import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../shared/widgets/button_x.dart';
import '../shared/widgets/dialog_x.dart';
import '../translations/translation_extension.dart';
import 'products_management_service.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('productCreatedSuccess'.tr),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true); // Return true to indicate success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'productCreatedFailed'.tr),
          backgroundColor: Colors.red,
        ),
      );
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
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'productName'.tr,
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'productNameRequired'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'description'.tr,
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
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
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'category'.tr,
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'categoryRequired'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // SKU
              TextFormField(
                controller: _skuController,
                decoration: InputDecoration(
                  labelText: 'sku'.tr,
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
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
                    child: TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'price'.tr,
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                    child: TextFormField(
                      controller: _stockController,
                      decoration: InputDecoration(
                        labelText: 'stock'.tr,
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
          child: ButtonX(
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            icon: Icons.close,
            label: 'cancel'.tr,
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ButtonX(
            onPressed: _isSubmitting ? null : _handleSubmit,
            icon: Icons.save,
            label: _isSubmitting ? 'saving'.tr : 'save'.tr,
            backgroundColor: const Color(0xFF34C759),
          ),
        ),
      ],
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';

import '../../categories/models/category_model.dart';
import '../../categories/services/categories_management_service.dart';
import '../../shared/config/api_config.dart';
import '../../shared/widgets/dialog_x.dart';
import '../../shared/widgets/gray_button_x.dart';
import '../../shared/widgets/green_button_x.dart';
import '../../shared/widgets/image_x.dart';
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
  final _skuController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  bool _isActive = true;
  bool _isSubmitting = false;
  bool _isUploading = false;
  bool _isLoadingCategories = true;
  String? _uploadedImagePath;
  List<CategoryModel> _categories = [];
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    TranslationService.setLanguage(widget.languageCode);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final service = CategoriesManagementService();
    final response = await service.getCategories(activeOnly: true);
    if (mounted && response.data != null) {
      setState(() {
        _categories = response.data!.data;
        _isLoadingCategories = false;
      });
    } else {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(File imageFile) async {
    setState(() {
      _isUploading = true;
    });
    try {
      final fileSize = imageFile.lengthSync();
      if (fileSize > 5 * 1024 * 1024) {
        if (!mounted) return;
        ToastX.error(context, 'fileSizeExceeded'.tr);
        setState(() {
          _isUploading = false;
        });
        return;
      }
      setState(() {
        _uploadedImagePath = imageFile.path;
        _isUploading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ToastX.error(context, '\${"imagePickFailed".tr}: \$e');
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null) {
      ToastX.error(context, 'pleaseSelectCategory'.tr);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final response = await ProductsManagementService.createProduct(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      categoryId: _selectedCategoryId!,
      sku: _skuController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      stock: int.parse(_stockController.text.trim()),
      isActive: _isActive,
    );

    if (!mounted) return;

    // If product created successfully and there's an image, upload it
    if (response.statusCode == 200 && _uploadedImagePath != null) {
      final productId = response.data?['id'];
      if (productId != null) {
        final uploadResponse =
            await ProductsManagementService.uploadProductImage(
              productId: productId,
              imageFile: File(_uploadedImagePath!),
            );

        if (uploadResponse.statusCode != 200) {
          if (!mounted) return;
          // Product created but photo upload failed
          ToastX.error(
            context,
            '${'productCreatedSuccess'.tr}, ${'photoUploadFailed'.tr}',
          );
          setState(() {
            _isSubmitting = false;
          });
          Navigator.of(context).pop(true);
          return;
        }
      }
    }

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

  Widget _buildPhotoSection() {
    return Center(
      child: ImageX(
        imageUrl: null,
        localImagePath: _uploadedImagePath,
        baseUrl: ApiConfig.baseUrl,
        size: 120,
        cornerRadius: 8,
        onPicked: _pickImage,
        isLoading: _isUploading,
        isUserPhoto: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DialogX(
      title: 'addProduct'.tr,
      width: 700,
      onClose: () => Navigator.of(context).pop(),
      content: Form(
        key: _formKey,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(
            context,
          ).copyWith(physics: const ClampingScrollPhysics()),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Photo section
                _buildPhotoSection(),
                const SizedBox(height: 16),

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

                // Category Dropdown
                _isLoadingCategories
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<int>(
                        value: _selectedCategoryId,
                        decoration: InputDecoration(
                          labelText: 'category'.tr,
                          border: const OutlineInputBorder(),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem<int>(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
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
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: GrayButtonX(
                onClicked: _isSubmitting
                    ? null
                    : () => Navigator.of(context).pop(),
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
        ),
      ],
    );
  }
}

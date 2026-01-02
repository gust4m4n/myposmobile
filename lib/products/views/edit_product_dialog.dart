import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../home/models/product_model.dart';
import '../../shared/config/api_config.dart';
import '../../shared/utils/image_upload_service.dart';
import '../../shared/widgets/button_x.dart';
import '../../shared/widgets/dialog_x.dart';
import '../../shared/widgets/gray_button_x.dart';
import '../../shared/widgets/green_button_x.dart';
import '../../shared/widgets/multiline_text_field_x.dart';
import '../../shared/widgets/red_button_x.dart';
import '../../shared/widgets/text_field_x.dart';
import '../../shared/widgets/toast_x.dart';
import '../../translations/translation_extension.dart';
import '../services/products_management_service.dart';

class EditProductDialog extends StatefulWidget {
  final String languageCode;
  final ProductModel product;

  const EditProductDialog({
    super.key,
    required this.languageCode,
    required this.product,
  });

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _skuController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late bool _isActive;
  bool _isSubmitting = false;
  bool _isUploadingPhoto = false;
  bool _isDeletingPhoto = false;
  String? _photoPath;
  String? _selectedPhotoPath;

  @override
  void initState() {
    super.initState();
    TranslationService.setLanguage(widget.languageCode);

    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController = TextEditingController(
      text: widget.product.description ?? '',
    );
    _categoryController = TextEditingController(text: widget.product.category);
    _skuController = TextEditingController(text: widget.product.sku ?? '');
    _priceController = TextEditingController(
      text: widget.product.price.toStringAsFixed(0),
    );
    _stockController = TextEditingController(
      text: (widget.product.stock ?? 0).toString(),
    );
    _isActive = widget.product.isActive ?? true;
    _photoPath = widget.product.image;
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

  Future<void> _pickPhoto() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final file = File(filePath);

        if (kDebugMode) {
          print('📷 Selected photo: $filePath');
          print('📷 File exists: ${file.existsSync()}');
          print('📷 File size: ${file.lengthSync()} bytes');
        }

        // Check file size (max 5MB)
        final fileSize = file.lengthSync();
        if (fileSize > 5 * 1024 * 1024) {
          if (!mounted) return;
          ToastX.error(context, 'photoTooLarge'.tr);
          return;
        }

        setState(() {
          _selectedPhotoPath = file.path;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking photo: $e');
      }
      if (!mounted) return;
      ToastX.error(context, 'photoPickFailed'.tr);
    }
  }

  // ignore: unused_element
  Future<void> _uploadPhotoUnused() async {
    if (_selectedPhotoPath == null || widget.product.id == null) return;

    setState(() {
      _isUploadingPhoto = true;
    });

    final response = await ImageUploadService.uploadProductPhoto(
      productId: widget.product.id!,
      filePath: _selectedPhotoPath!,
    );

    if (!mounted) return;

    setState(() {
      _isUploadingPhoto = false;
    });

    if (response.statusCode == 200) {
      ToastX.success(context, 'photoUploadedSuccess'.tr);

      // Update photo path from response
      if (response.data != null && response.data!['image'] != null) {
        setState(() {
          _photoPath = response.data!['image'];
          _selectedPhotoPath = null;
        });
      }
    } else {
      ToastX.error(context, response.message ?? 'photoUploadFailed'.tr);
    }
  }

  // ignore: unused_element
  Future<void> _deletePhotoUnused() async {
    if (_photoPath == null || widget.product.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => DialogX(
        title: 'deletePhoto'.tr,
        content: Text('deletePhotoConfirmation'.tr),
        actions: [
          GrayButtonX(
            onClicked: () => Navigator.pop(context, false),
            title: 'cancel'.tr,
          ),
          RedButtonX(
            onClicked: () => Navigator.pop(context, true),
            title: 'delete'.tr,
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isDeletingPhoto = true;
    });

    final response = await ImageUploadService.deleteProductPhoto(
      productId: widget.product.id!,
    );

    if (!mounted) return;

    setState(() {
      _isDeletingPhoto = false;
    });

    if (response.statusCode == 200) {
      ToastX.success(context, 'photoDeletedSuccess'.tr);
      setState(() {
        _photoPath = null;
        _selectedPhotoPath = null;
      });
    } else {
      ToastX.error(context, response.message ?? 'photoDeleteFailed'.tr);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate() || widget.product.id == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Upload photo first if there's a selected photo
    if (_selectedPhotoPath != null) {
      final uploadResponse = await ImageUploadService.uploadProductPhoto(
        productId: widget.product.id!,
        filePath: _selectedPhotoPath!,
      );

      if (uploadResponse.statusCode != 200) {
        if (!mounted) return;
        setState(() {
          _isSubmitting = false;
        });
        ToastX.error(context, uploadResponse.message ?? 'photoUploadFailed'.tr);
        return;
      }

      // Update photo path from response
      if (uploadResponse.data != null &&
          uploadResponse.data!['image'] != null) {
        _photoPath = uploadResponse.data!['image'];
        _selectedPhotoPath = null;
      }
    }

    final response = await ProductsManagementService.updateProduct(
      id: widget.product.id!,
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
      ToastX.success(context, 'productUpdatedSuccess'.tr);
      Navigator.of(context).pop(true); // Return true to indicate success
    } else {
      ToastX.error(context, response.message ?? 'productUpdatedFailed'.tr);
    }
  }

  Widget _buildPhotoSection() {
    final theme = Theme.of(context);
    final bool hasSelectedPhoto = _selectedPhotoPath != null;
    final bool hasExistingPhoto = _photoPath != null;
    final String? displayPhotoUrl = hasExistingPhoto
        ? (_photoPath!.startsWith('http')
              ? _photoPath
              : '${ApiConfig.baseUrl}$_photoPath')
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'productPhoto'.tr,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Photo preview with change button
          Center(
            child: Stack(
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: hasSelectedPhoto
                        ? Image.file(
                            File(_selectedPhotoPath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image, size: 64);
                            },
                          )
                        : hasExistingPhoto
                        ? Image.network(
                            displayPhotoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image, size: 64);
                            },
                          )
                        : Icon(Icons.image, size: 64, color: Colors.grey[600]),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: SizedBox(
                    height: 32,
                    child: ButtonX(
                      onClicked: _isUploadingPhoto || _isDeletingPhoto
                          ? null
                          : _pickPhoto,
                      label: 'change'.tr,
                      backgroundColor: Colors.white.withValues(alpha: 0.5),
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DialogX(
      title: 'editProduct'.tr,
      width: 700,
      onClose: () => Navigator.of(context).pop(),
      content: Form(
        key: _formKey,
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

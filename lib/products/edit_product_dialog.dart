import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../home/product_model.dart';
import '../shared/utils/image_upload_service.dart';
import '../shared/widgets/button_x.dart';
import '../shared/widgets/dialog_x.dart';
import '../shared/widgets/image_crop_editor.dart';
import '../translations/translation_extension.dart';
import 'products_management_service.dart';

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('photoTooLarge'.tr),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Open crop editor
        if (mounted) {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ImageCropEditor(
                imageFile: file,
                onCancel: () => Navigator.of(context).pop(),
                onCropComplete: (croppedFile) {
                  Navigator.of(context).pop();
                  setState(() {
                    _selectedPhotoPath = croppedFile.path;
                  });
                },
              ),
              fullscreenDialog: true,
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking photo: $e');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('photoPickFailed'.tr),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadPhoto() async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('photoUploadedSuccess'.tr),
          backgroundColor: Colors.green,
        ),
      );

      // Update photo path from response
      if (response.data != null && response.data!['image'] != null) {
        setState(() {
          _photoPath = response.data!['image'];
          _selectedPhotoPath = null;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'photoUploadFailed'.tr),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deletePhoto() async {
    if (_photoPath == null || widget.product.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('deletePhoto'.tr),
        content: Text('deletePhotoConfirmation'.tr),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('photoDeletedSuccess'.tr),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _photoPath = null;
        _selectedPhotoPath = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'photoDeleteFailed'.tr),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate() || widget.product.id == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('productUpdatedSuccess'.tr),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true); // Return true to indicate success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'productUpdatedFailed'.tr),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildPhotoSection() {
    final theme = Theme.of(context);
    final bool hasSelectedPhoto = _selectedPhotoPath != null;
    final bool hasExistingPhoto = _photoPath != null;
    final String? displayPhotoUrl = hasExistingPhoto
        ? (_photoPath!.startsWith('http')
              ? _photoPath
              : 'http://localhost:8080$_photoPath')
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

          // Photo preview
          Center(
            child: Container(
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
          ),
          const SizedBox(height: 16),

          // Action buttons
          if (hasSelectedPhoto) ...[
            Row(
              children: [
                Expanded(
                  child: ButtonX(
                    onPressed: _isUploadingPhoto
                        ? null
                        : () => setState(() => _selectedPhotoPath = null),
                    icon: Icons.close,
                    label: 'cancel'.tr,
                    backgroundColor: theme.colorScheme.surface,
                    foregroundColor: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ButtonX(
                    onPressed: _isUploadingPhoto ? null : _uploadPhoto,
                    icon: Icons.upload,
                    label: _isUploadingPhoto ? 'uploading'.tr : 'upload'.tr,
                    backgroundColor: const Color(0xFF007AFF),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: ButtonX(
                    onPressed: _isUploadingPhoto || _isDeletingPhoto
                        ? null
                        : _pickPhoto,
                    icon: Icons.photo_library,
                    label: 'selectPhoto'.tr,
                    backgroundColor: const Color(0xFF007AFF),
                  ),
                ),
                if (hasExistingPhoto) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ButtonX(
                      onPressed: _isUploadingPhoto || _isDeletingPhoto
                          ? null
                          : _deletePhoto,
                      icon: Icons.delete,
                      label: _isDeletingPhoto
                          ? 'deleting'.tr
                          : 'deletePhoto'.tr,
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          ],
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

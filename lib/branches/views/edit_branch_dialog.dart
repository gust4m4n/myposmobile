import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../shared/config/api_config.dart';
import '../../shared/widgets/button_x.dart';
import '../../shared/widgets/dialog_x.dart';
import '../../shared/widgets/toast_x.dart';
import '../../tenants/models/tenant_model.dart';
import '../../translations/translation_extension.dart';
import '../models/branch_model.dart';
import '../services/branches_management_service.dart';

class EditBranchDialog extends StatefulWidget {
  final String languageCode;
  final TenantModel tenant;
  final BranchModel branch;

  const EditBranchDialog({
    super.key,
    required this.languageCode,
    required this.tenant,
    required this.branch,
  });

  @override
  State<EditBranchDialog> createState() => _EditBranchDialogState();
}

class _EditBranchDialogState extends State<EditBranchDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _websiteController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late bool _isActive;
  bool _isSubmitting = false;
  String? _existingImageUrl;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    TranslationService.setLanguage(widget.languageCode);

    _nameController = TextEditingController(text: widget.branch.name);
    _descriptionController = TextEditingController(
      text: widget.branch.description ?? '',
    );
    _addressController = TextEditingController(
      text: widget.branch.address ?? '',
    );
    _websiteController = TextEditingController(
      text: widget.branch.website ?? '',
    );
    _emailController = TextEditingController(text: widget.branch.email ?? '');
    _phoneController = TextEditingController(text: widget.branch.phone ?? '');
    _isActive = widget.branch.isActive ?? true;
    _existingImageUrl = widget.branch.image;

    // Prefill form with updated test data in debug mode
    if (kDebugMode) {
      _nameController.text =
          'Updated ${widget.branch.name} ${DateTime.now().millisecondsSinceEpoch % 1000}';
      _descriptionController.text =
          'This is an UPDATED test branch description modified in debug mode for development purposes';
      _addressController.text =
          'Jl. Kuningan Raya No. 789, Jakarta Selatan, DKI Jakarta 12940';
      _websiteController.text = 'https://www.updated-testbranch.com';
      _emailController.text = 'updated@testbranch.com';
      _phoneController.text = '021-11223344';
      print('🐛 Debug mode: Edit branch form prefilled with updated test data');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
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
          print('📷 Selected image: $filePath');
          print('📷 File exists: ${file.existsSync()}');
          print('📷 File size: ${file.lengthSync()} bytes');
        }

        // Check file size (max 5MB)
        final fileSize = file.lengthSync();
        if (fileSize > 5 * 1024 * 1024) {
          if (!mounted) return;
          ToastX.error(context, 'fileSizeExceeded'.tr);
          return;
        }

        setState(() {
          _selectedImage = file;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error picking image: $e');
      }
      if (!mounted) return;
      ToastX.error(context, '\${"imagePickFailed".tr}: \$e');
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final service = BranchesManagementService();
      final response = await service.updateBranch(
        branchId: widget.branch.id!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        address: _addressController.text.trim(),
        website: _websiteController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        isActive: _isActive,
        image: _selectedImage,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        Navigator.of(context).pop(true);
      } else {
        ToastX.error(context, response.message ?? 'branchUpdateFailed'.tr);
      }
    } catch (e) {
      if (!mounted) return;
      ToastX.error(context, '\${"branchUpdateFailed".tr}: \$e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _existingImageUrl != null
        ? '${ApiConfig.baseUrl}$_existingImageUrl'
        : null;

    return DialogX(
      title: '${'editBranch'.tr} - ${widget.tenant.name}',
      width: 600,
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              if (_selectedImage != null || imageUrl != null) ...[
                Center(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _selectedImage != null
                            ? Image.file(
                                _selectedImage!,
                                height: 150,
                                width: 150,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                imageUrl!,
                                height: 150,
                                width: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 150,
                                    width: 150,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.store,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                      ),
                      if (_selectedImage != null)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black54,
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedImage = null;
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Change Image Button
              Center(
                child: ButtonX(
                  onPressed: _pickImage,
                  label: 'changeImage'.tr,
                  backgroundColor: Colors.white.withOpacity(0.5),
                  foregroundColor: Colors.black,
                ),
              ),
              const SizedBox(height: 24),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '${'name'.tr} *',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'fieldRequired'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: '${'description'.tr} *',
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'fieldRequired'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Address
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: '${'address'.tr} *',
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'fieldRequired'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Website
              TextFormField(
                controller: _websiteController,
                decoration: InputDecoration(
                  labelText: '${'website'.tr} *',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'fieldRequired'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: '${'email'.tr} *',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'fieldRequired'.tr;
                  }
                  if (!value.contains('@')) {
                    return 'invalidEmail'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: '${'phone'.tr} *',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'fieldRequired'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Is Active
              SwitchListTile(
                title: Text('active'.tr),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text('cancel'.tr),
        ),
        ButtonX(
          onPressed: _isSubmitting ? null : _handleSubmit,
          label: _isSubmitting ? 'saving'.tr : 'save'.tr,
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
}

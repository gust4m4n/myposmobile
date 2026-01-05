import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../shared/config/api_config.dart';
import '../../shared/widgets/dialog_x.dart';
import '../../shared/widgets/gray_button_x.dart';
import '../../shared/widgets/green_button_x.dart';
import '../../shared/widgets/image_x.dart';
import '../../shared/widgets/multiline_text_field_x.dart';
import '../../shared/widgets/text_field_x.dart';
import '../../shared/widgets/toast_x.dart';
import '../../translations/translation_extension.dart';
import '../models/tenant_model.dart';
import '../services/tenants_management_service.dart';

class EditTenantDialog extends StatefulWidget {
  final String languageCode;
  final TenantModel tenant;

  const EditTenantDialog({
    super.key,
    required this.languageCode,
    required this.tenant,
  });

  @override
  State<EditTenantDialog> createState() => _EditTenantDialogState();
}

class _EditTenantDialogState extends State<EditTenantDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _websiteController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late bool _isActive;
  bool _isSubmitting = false;
  bool _isUploading = false;
  String? _existingImageUrl;
  String? _uploadedImagePath;

  @override
  void initState() {
    super.initState();
    TranslationService.setLanguage(widget.languageCode);

    _nameController = TextEditingController(text: widget.tenant.name);
    _descriptionController = TextEditingController(
      text: widget.tenant.description ?? '',
    );
    _addressController = TextEditingController(
      text: widget.tenant.address ?? '',
    );
    _websiteController = TextEditingController(
      text: widget.tenant.website ?? '',
    );
    _emailController = TextEditingController(text: widget.tenant.email ?? '');
    _phoneController = TextEditingController(text: widget.tenant.phone ?? '');
    _isActive = widget.tenant.isActive ?? true;
    _existingImageUrl = widget.tenant.image;

    // Prefill form with updated test data in debug mode
    if (kDebugMode) {
      _nameController.text =
          'Updated ${widget.tenant.name} ${DateTime.now().millisecondsSinceEpoch % 1000}';
      _descriptionController.text =
          'This is an UPDATED test tenant description modified in debug mode for development purposes';
      _addressController.text =
          'Jl. Gatot Subroto No. 456, Jakarta Selatan, DKI Jakarta 12930';
      _websiteController.text = 'https://www.updated-testtenant.com';
      _emailController.text = 'updated@testtenant.com';
      _phoneController.text = '021-87654321';
      print('🐛 Debug mode: Edit form prefilled with updated test data');
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

  Future<void> _pickImage(File imageFile) async {
    setState(() {
      _isUploading = true;
    });

    try {
      if (kDebugMode) {
        print('📷 Selected image: ${imageFile.path}');
        print('📷 File size: ${imageFile.lengthSync()} bytes');
      }

      // Check file size (max 5MB)
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
        _existingImageUrl = null;
        _isUploading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error handling image: $e');
      }
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

    setState(() {
      _isSubmitting = true;
    });

    try {
      final service = TenantsManagementService();
      final response = await service.updateTenant(
        id: widget.tenant.id!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        address: _addressController.text.trim(),
        website: _websiteController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        isActive: _isActive,
        imageFile: _uploadedImagePath != null
            ? File(_uploadedImagePath!)
            : null,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ToastX.success(context, 'tenantUpdatedSuccess'.tr);
        Navigator.of(context).pop(true);
      } else {
        ToastX.error(context, response.message ?? 'tenantUpdateFailed'.tr);
      }
    } catch (e) {
      if (!mounted) return;
      ToastX.error(context, '\${"tenantUpdateFailed".tr}: \$e');
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
    return DialogX(
      title: 'editTenant'.tr,
      width: 600,
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Center(
                child: ImageX(
                  imageUrl: _existingImageUrl,
                  localImagePath: _uploadedImagePath,
                  baseUrl: ApiConfig.baseUrl,
                  size: 120,
                  cornerRadius: 8,
                  onPicked: _pickImage,
                  isLoading: _isUploading,
                ),
              ),
              const SizedBox(height: 24),

              // Name
              TextFieldX(
                controller: _nameController,
                hintText: '${'name'.tr} *',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'fieldRequired'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              MultilineTextFieldX(
                controller: _descriptionController,
                hintText: '${'description'.tr} *',
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
              MultilineTextFieldX(
                controller: _addressController,
                hintText: '${'address'.tr} *',
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
              TextFieldX(
                controller: _websiteController,
                hintText: '${'website'.tr} *',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'fieldRequired'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email
              TextFieldX(
                controller: _emailController,
                hintText: '${'email'.tr} *',
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
              TextFieldX(
                controller: _phoneController,
                hintText: '${'phone'.tr} *',
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
        GrayButtonX(
          onClicked: _isSubmitting ? null : () => Navigator.of(context).pop(),
          title: 'cancel'.tr,
          enabled: !_isSubmitting,
        ),
        GreenButtonX(
          onClicked: _isSubmitting ? null : _handleSubmit,
          title: _isSubmitting ? 'saving'.tr : 'save'.tr,
          enabled: !_isSubmitting,
        ),
      ],
    );
  }
}

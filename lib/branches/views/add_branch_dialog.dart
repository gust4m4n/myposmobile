import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../shared/widgets/dialog_x.dart';
import '../../shared/widgets/gray_button_x.dart';
import '../../shared/widgets/green_button_x.dart';
import '../../shared/widgets/image_x.dart';
import '../../shared/widgets/text_field_x.dart';
import '../../shared/widgets/toast_x.dart';
import '../../tenants/models/tenant_model.dart';
import '../../translations/translation_extension.dart';
import '../services/branches_management_service.dart';

class AddBranchDialog extends StatefulWidget {
  final String languageCode;
  final TenantModel tenant;

  const AddBranchDialog({
    super.key,
    required this.languageCode,
    required this.tenant,
  });

  @override
  State<AddBranchDialog> createState() => _AddBranchDialogState();
}

class _AddBranchDialogState extends State<AddBranchDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _websiteController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isActive = true;
  bool _isSubmitting = false;
  bool _isUploading = false;
  String? _uploadedImagePath;

  @override
  void initState() {
    super.initState();
    TranslationService.setLanguage(widget.languageCode);

    // Prefill form in debug mode
    if (kDebugMode) {
      _nameController.text =
          'Test Branch ${DateTime.now().millisecondsSinceEpoch % 1000}';
      _descriptionController.text =
          'This is a test branch created in debug mode for development purposes';
      _addressController.text =
          'Jl. Jenderal Sudirman No. 321, Jakarta Pusat, DKI Jakarta 10220';
      _websiteController.text = 'https://www.testbranch.com';
      _emailController.text = 'contact@testbranch.com';
      _phoneController.text = '021-55667788';
      _isActive = true;
      print('🐛 Debug mode: Add branch form prefilled with test data');
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

    setState(() {
      _isSubmitting = true;
    });

    try {
      final service = BranchesManagementService();
      final response = await service.createBranch(
        tenantId: widget.tenant.id!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        address: _addressController.text.trim(),
        website: _websiteController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        isActive: _isActive,
        image: _uploadedImagePath != null ? File(_uploadedImagePath!) : null,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ToastX.success(context, 'branchCreatedSuccess'.tr);
        Navigator.of(context).pop(true);
      } else {
        ToastX.error(context, response.message ?? 'branchCreationFailed'.tr);
      }
    } catch (e) {
      if (!mounted) return;
      ToastX.error(context, '\${"branchCreationFailed".tr}: \$e');
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
      title: '${'addBranch'.tr} - ${widget.tenant.name}',
      width: 600,
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ImageX(
                  imageUrl: null,
                  baseUrl: null,
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
              TextFieldX(
                controller: _descriptionController,
                hintText: '${'description'.tr} *',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'fieldRequired'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Address
              TextFieldX(
                controller: _addressController,
                hintText: '${'address'.tr} *',
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

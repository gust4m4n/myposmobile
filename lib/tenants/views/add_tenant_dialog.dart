import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../shared/widgets/dialog_x.dart';
import '../../shared/widgets/gray_button_x.dart';
import '../../shared/widgets/green_button_x.dart';
import '../../shared/widgets/image_x.dart';
import '../../shared/widgets/multiline_text_field_x.dart';
import '../../shared/widgets/text_field_x.dart';
import '../../shared/widgets/toast_x.dart';
import '../../translations/translation_extension.dart';
import '../services/tenants_management_service.dart';

class AddTenantDialog extends StatefulWidget {
  final String languageCode;

  const AddTenantDialog({super.key, required this.languageCode});

  @override
  State<AddTenantDialog> createState() => _AddTenantDialogState();
}

class _AddTenantDialogState extends State<AddTenantDialog> {
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
          'Test Tenant ${DateTime.now().millisecondsSinceEpoch % 1000}';
      _descriptionController.text =
          'This is a test tenant created in debug mode for development purposes';
      _addressController.text =
          'Jl. Sudirman No. 123, Jakarta Selatan, DKI Jakarta 12190';
      _websiteController.text = 'https://www.testtenant.com';
      _emailController.text = 'contact@testtenant.com';
      _phoneController.text = '021-12345678';
      _isActive = true;
      print('🐛 Debug mode: Form prefilled with test data');
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
        _isUploading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error handling image: $e');
      }
      if (!mounted) return;
      ToastX.error(context, 'imagePickFailed: $e');
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
      if (kDebugMode) {
        print('🔵 Creating tenant...');
        print('  Name: ${_nameController.text.trim()}');
        print('  Email: ${_emailController.text.trim()}');
        print('  Phone: ${_phoneController.text.trim()}');
        print('  Image: ${_uploadedImagePath ?? "null"}');
      }

      final service = TenantsManagementService();
      final response = await service.createTenant(
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

      if (kDebugMode) {
        print('📡 Response status: ${response.statusCode}');
        print('📡 Response data: ${response.data}');
        print('📡 Response error: ${response.error}');
        print('📡 Response message: ${response.message}');
      }

      if (!mounted) return;

      if (response.statusCode == 200) {
        ToastX.success(context, 'tenantCreatedSuccess'.tr);
        Navigator.of(context).pop(true);
      } else {
        ToastX.error(context, response.message ?? 'tenantCreationFailed'.tr);
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error creating tenant: $e');
        print('❌ Stack trace: $stackTrace');
      }
      if (!mounted) return;
      ToastX.error(context, '\${"tenantCreationFailed".tr}: \$e');
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
      title: 'addTenant'.tr,
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
                  imageUrl: null,
                  localImagePath: _uploadedImagePath,
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

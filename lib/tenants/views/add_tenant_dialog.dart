import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../shared/widgets/button_x.dart';
import '../../shared/widgets/dialog_x.dart';
import '../../shared/widgets/green_button.dart';
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
  File? _selectedImage;

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
      if (kDebugMode) {
        print('🔵 Creating tenant...');
        print('  Name: ${_nameController.text.trim()}');
        print('  Email: ${_emailController.text.trim()}');
        print('  Phone: ${_phoneController.text.trim()}');
        print('  Image: ${_selectedImage?.path ?? "null"}');
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
        imageFile: _selectedImage,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              if (_selectedImage != null) ...[
                Center(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImage!,
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
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

              // Change/Select Image Button
              Center(
                child: ButtonX(
                  onClicked: _pickImage,
                  label: _selectedImage == null
                      ? 'selectImage'.tr
                      : 'changeImage'.tr,
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
        GreenButton(
          onClicked: _isSubmitting ? null : _handleSubmit,
          title: _isSubmitting ? 'saving'.tr : 'save'.tr,
        ),
      ],
    );
  }
}

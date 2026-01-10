import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myposmobile/shared/widgets/red_button_x.dart';

import '../../shared/widgets/dialog_x.dart';
import '../../shared/widgets/gray_button_x.dart';
import '../../shared/widgets/green_button_x.dart';
import '../../shared/widgets/image_x.dart';
import '../../shared/widgets/text_field_x.dart';
import '../../shared/widgets/toast_x.dart';
import '../../translations/translation_extension.dart';
import '../models/branch_model.dart';
import '../services/branches_management_service.dart';

class EditBranchDialog extends StatefulWidget {
  final String languageCode;
  final BranchModel branch;

  const EditBranchDialog({
    super.key,
    required this.languageCode,
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
  bool _isUploading = false;
  String? _existingImageUrl;
  String? _uploadedImagePath;

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
        _existingImageUrl = null;
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
      final response = await service.updateBranch(
        branchId: widget.branch.id!,
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
    return DialogX(
      title: 'editBranch'.tr,
      width: 600,
      onClose: _isSubmitting ? null : () => Navigator.of(context).pop(),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Center(
                child: ImageX(
                  imageUrl: _existingImageUrl,
                  localImagePath: _uploadedImagePath,
                  baseUrl: 'http://localhost:8080',
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
            ],
          ),
        ),
      ),
      actions: [
        RedButtonX(
          onClicked: _isSubmitting
              ? null
              : () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => DialogX(
                      title: 'deleteBranch'.tr,
                      content: Text(
                        '${'deleteBranchConfirmation'.tr} "${widget.branch.name}"?',
                      ),
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

                  if (confirm == true && mounted) {
                    setState(() {
                      _isSubmitting = true;
                    });

                    try {
                      final service = BranchesManagementService();
                      final response = await service.deleteBranch(
                        widget.branch.id!,
                      );

                      if (!mounted) return;

                      if (response.statusCode == 200) {
                        ToastX.success(context, 'branchDeletedSuccess'.tr);
                        Navigator.of(context).pop(true);
                      } else {
                        ToastX.error(
                          context,
                          response.message ?? 'branchDeleteFailed'.tr,
                        );
                      }
                    } catch (e) {
                      if (!mounted) return;
                      ToastX.error(context, '${'branchDeleteFailed'.tr}: $e');
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isSubmitting = false;
                        });
                      }
                    }
                  }
                },
          title: 'delete'.tr,
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

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
import '../services/users_management_service.dart';

class EditUserDialog extends StatefulWidget {
  final Map<String, dynamic> user;
  final String languageCode;
  final VoidCallback onSuccess;

  const EditUserDialog({
    super.key,
    required this.user,
    required this.languageCode,
    required this.onSuccess,
  });

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _fullNameController;
  late final TextEditingController _branchIdController;
  final _passwordController = TextEditingController();
  late String _selectedRole;
  late bool _isActive;
  bool _isSubmitting = false;
  bool _isUploading = false;
  String? _existingImageUrl;
  String? _uploadedImagePath;

  final List<String> _roles = ['staff', 'branchadmin', 'tenantadmin'];

  @override
  void initState() {
    super.initState();
    TranslationService.setLanguage(widget.languageCode);

    _emailController = TextEditingController(text: widget.user['email'] ?? '');
    _fullNameController = TextEditingController(
      text: widget.user['full_name'] ?? '',
    );
    _branchIdController = TextEditingController(
      text: widget.user['branch_id']?.toString() ?? '',
    );
    _selectedRole = widget.user['role'] ?? 'staff';
    _isActive = widget.user['is_active'] ?? true;
    _existingImageUrl = widget.user['image'] as String?;

    // Prefill form with updated test data in debug mode
    if (kDebugMode) {
      _fullNameController.text =
          '${widget.user['full_name']} (Edited ${DateTime.now().millisecondsSinceEpoch % 1000})';
      // Keep email unchanged to avoid "email already exists" error
      // _passwordController can be left empty or filled if you want to test password change
      print('🐛 Debug mode: Edit user form prefilled with updated test data');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    _branchIdController.dispose();
    _passwordController.dispose();
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

    final userId = widget.user['id'] as int;
    final password = _passwordController.text.trim();

    final response = await UsersManagementService.updateUser(
      id: userId,
      email: _emailController.text.trim(),
      fullName: _fullNameController.text.trim(),
      role: _selectedRole,
      branchId: int.parse(_branchIdController.text.trim()),
      isActive: _isActive,
      password: password.isNotEmpty ? password : null,
      imageFile: _uploadedImagePath != null ? File(_uploadedImagePath!) : null,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (response.statusCode == 200) {
      ToastX.success(context, 'userUpdatedSuccess'.tr);
      Navigator.of(context).pop();
      widget.onSuccess();
    } else {
      ToastX.error(context, response.message ?? 'userUpdatedFailed'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogX(
      title: 'editUser'.tr,
      width: 600,
      onClose: () => Navigator.of(context).pop(),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

              // Full Name Field
              TextFieldX(
                controller: _fullNameController,
                hintText: 'fullName'.tr,
                prefixIcon: Icons.badge,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'fullNameRequired'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email Field
              TextFieldX(
                controller: _emailController,
                hintText: 'email'.tr,
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'emailRequired'.tr;
                  }
                  if (!value.contains('@')) {
                    return 'emailInvalid'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password Field (Optional)
              TextFieldX(
                controller: _passwordController,
                hintText:
                    '${'password'.tr} (${'optional'.tr}) - ${'leaveEmptyToKeepCurrent'.tr}',
                prefixIcon: Icons.lock,
                obscureText: true,
                validator: (value) {
                  if (value != null &&
                      value.trim().isNotEmpty &&
                      value.trim().length < 6) {
                    return 'passwordMinLength'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Role Dropdown
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  labelText: 'role'.tr,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.security),
                ),
                items: _roles.map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRole = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Branch ID Field
              TextFormField(
                controller: _branchIdController,
                decoration: InputDecoration(
                  labelText: 'branchId'.tr,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.store),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'branchIdRequired'.tr;
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return 'branchIdInvalid'.tr;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: RedButtonX(
                onClicked: _isSubmitting
                    ? null
                    : () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => DialogX(
                            title: 'deleteUser'.tr,
                            content: Text(
                              'confirmDeleteUser'.tr.replaceAll(
                                '{username}',
                                widget.user['email'] ?? '',
                              ),
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
                            final response =
                                await UsersManagementService.deleteUser(
                                  widget.user['id'] as int,
                                );

                            if (!mounted) return;

                            if (response.statusCode == 200) {
                              ToastX.success(context, 'userDeletedSuccess'.tr);
                              Navigator.of(context).pop();
                              widget.onSuccess();
                            } else {
                              ToastX.error(
                                context,
                                response.message ?? 'userDeleteFailed'.tr,
                              );
                            }
                          } catch (e) {
                            if (!mounted) return;
                            ToastX.error(
                              context,
                              '${'userDeleteFailed'.tr}: $e',
                            );
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

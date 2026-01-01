import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../shared/config/api_config.dart';
import '../../shared/widgets/button_x.dart';
import '../../shared/widgets/dialog_x.dart';
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
  String? _existingImageUrl;
  File? _selectedImage;

  final List<String> _roles = ['user', 'branchadmin', 'tenantadmin'];

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
    _selectedRole = widget.user['role'] ?? 'user';
    _isActive = widget.user['is_active'] ?? true;
    _existingImageUrl = widget.user['image'] as String?;

    // Prefill form with updated test data in debug mode
    if (kDebugMode) {
      _fullNameController.text =
          'Updated ${widget.user['full_name']} ${DateTime.now().millisecondsSinceEpoch % 1000}';
      _emailController.text = 'updated.${widget.user['email']}';
      _passwordController.text = 'NewPassword123!';
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
      imageFile: _selectedImage,
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
    final theme = Theme.of(context);
    final imageUrl = _existingImageUrl != null
        ? '${ApiConfig.baseUrl}$_existingImageUrl'
        : null;

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
              // Image
              if (_selectedImage != null || imageUrl != null) ...[
                Center(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(75),
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
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person,
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

              // Full Name Field
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'fullName'.tr,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.badge),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'fullNameRequired'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'email'.tr,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email),
                ),
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
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '${'password'.tr} (${'optional'.tr})',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  hintText: 'leaveEmptyToKeepCurrent'.tr,
                ),
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
              const SizedBox(height: 16),

              // Active Status Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('activeStatus'.tr, style: const TextStyle(fontSize: 16)),
                  Switch(
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: ButtonX(
                onPressed: _isSubmitting
                    ? null
                    : () => Navigator.of(context).pop(),
                icon: Icons.close,
                label: 'cancel'.tr,
                backgroundColor: Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ButtonX(
                onPressed: _isSubmitting ? null : _handleSubmit,
                icon: Icons.save,
                label: _isSubmitting ? 'saving'.tr : 'save'.tr,
                backgroundColor: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

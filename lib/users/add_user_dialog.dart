import 'package:flutter/material.dart';

import '../shared/widgets/button_x.dart';
import '../shared/widgets/dialog_x.dart';
import '../translations/translation_extension.dart';
import 'users_management_service.dart';

class AddUserDialog extends StatefulWidget {
  final String languageCode;
  final VoidCallback onSuccess;

  const AddUserDialog({
    super.key,
    required this.languageCode,
    required this.onSuccess,
  });

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _branchIdController = TextEditingController();
  String _selectedRole = 'user';
  bool _isActive = true;
  bool _isSubmitting = false;

  final List<String> _roles = ['user', 'branchadmin', 'tenantadmin'];

  @override
  void initState() {
    super.initState();
    TranslationService.setLanguage(widget.languageCode);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _branchIdController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final response = await UsersManagementService.createUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      fullName: _fullNameController.text.trim(),
      role: _selectedRole,
      branchId: int.parse(_branchIdController.text.trim()),
      isActive: _isActive,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('userCreatedSuccess'.tr),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
      widget.onSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'userCreatedFailed'.tr),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DialogX(
      title: 'addUser'.tr,
      width: 600,
      onClose: () => Navigator.of(context).pop(),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

              // Password Field
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'password'.tr,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'passwordRequired'.tr;
                  }
                  if (value.trim().length < 6) {
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

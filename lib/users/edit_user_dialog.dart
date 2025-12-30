import 'package:flutter/material.dart';

import '../shared/widgets/button_x.dart';
import '../shared/widgets/dialog_x.dart';
import '../translations/translation_extension.dart';
import 'users_management_service.dart';

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
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _fullNameController;
  late final TextEditingController _branchIdController;
  final _passwordController = TextEditingController();
  late String _selectedRole;
  late bool _isActive;
  bool _isSubmitting = false;

  final List<String> _roles = ['user', 'branchadmin', 'tenantadmin'];

  @override
  void initState() {
    super.initState();
    TranslationService.setLanguage(widget.languageCode);

    _usernameController = TextEditingController(
      text: widget.user['username'] ?? '',
    );
    _emailController = TextEditingController(text: widget.user['email'] ?? '');
    _fullNameController = TextEditingController(
      text: widget.user['full_name'] ?? '',
    );
    _branchIdController = TextEditingController(
      text: widget.user['branch_id']?.toString() ?? '',
    );
    _selectedRole = widget.user['role'] ?? 'user';
    _isActive = widget.user['is_active'] ?? true;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _branchIdController.dispose();
    _passwordController.dispose();
    super.dispose();
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
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      fullName: _fullNameController.text.trim(),
      role: _selectedRole,
      branchId: int.parse(_branchIdController.text.trim()),
      isActive: _isActive,
      password: password.isNotEmpty ? password : null,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('userUpdatedSuccess'.tr),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
      widget.onSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'userUpdatedFailed'.tr),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              // Username Field
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'username'.tr,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'usernameRequired'.tr;
                  }
                  if (value.trim().length < 3) {
                    return 'usernameMinLength'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

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

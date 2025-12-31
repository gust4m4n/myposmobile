import 'package:flutter/material.dart';

import '../../shared/widgets/button_x.dart';
import '../../shared/widgets/dialog_x.dart';
import '../../translations/translation_extension.dart';
import '../services/profile_service.dart';

class EditProfileDialog extends StatefulWidget {
  final String languageCode;
  final String currentFullName;
  final String currentEmail;

  const EditProfileDialog({
    super.key,
    required this.languageCode,
    required this.currentFullName,
    required this.currentEmail,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _profileService = ProfileService();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    TranslationService.setLanguage(widget.languageCode);
    _fullNameController.text = widget.currentFullName;
    _emailController.text = widget.currentEmail;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final response = await _profileService.updateProfile(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('profileUpdatedSuccess'.tr),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true); // Return true to indicate success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'profileUpdateFailed'.tr),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DialogX(
      title: 'editProfile'.tr,
      width: 500,
      onClose: () => Navigator.of(context).pop(),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Full Name
            TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: 'fullName'.tr,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'fullNameRequired'.tr;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'email'.tr,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'emailRequired'.tr;
                }
                // Basic email validation
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'emailInvalid'.tr;
                }
                return null;
              },
            ),
          ],
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
                backgroundColor: theme.colorScheme.surface,
                foregroundColor: theme.colorScheme.onSurface,
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

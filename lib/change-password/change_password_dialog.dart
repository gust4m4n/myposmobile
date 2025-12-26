import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../shared/widgets/button_x.dart';
import '../shared/widgets/dialog_x.dart';
import '../translations/translation_extension.dart';
import 'change_password_service.dart';

class ChangePasswordDialog extends StatefulWidget {
  final String languageCode;

  const ChangePasswordDialog({super.key, required this.languageCode});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController(
    text: kDebugMode ? '123456' : '',
  );
  final _newPasswordController = TextEditingController(
    text: kDebugMode ? '123456' : '',
  );
  final _confirmPasswordController = TextEditingController(
    text: kDebugMode ? '123456' : '',
  );
  final _changePasswordService = ChangePasswordService();

  bool _isLoading = false;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await _changePasswordService.changePassword(
      oldPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;

    if (response.isSuccess) {
      // Clear form
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      // Close dialog and show success message
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('passwordChangedSuccessfully'.tr),
            backgroundColor: Colors.green,
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DialogX(
      title: 'changePassword'.tr,
      width: 500,
      onClose: () => Navigator.pop(context),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Old Password Field
            TextFormField(
              controller: _oldPasswordController,
              obscureText: _obscureOldPassword,
              decoration: InputDecoration(
                labelText: 'currentPassword'.tr,
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureOldPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureOldPassword = !_obscureOldPassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'pleaseEnterCurrentPassword'.tr;
                }
                return null;
              },
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // New Password Field
            TextFormField(
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              decoration: InputDecoration(
                labelText: 'newPassword'.tr,
                prefixIcon: const Icon(Icons.lock_open),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'pleaseEnterNewPassword'.tr;
                }
                if (value.length < 6) {
                  return 'passwordMustBe6Characters'.tr;
                }
                return null;
              },
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Confirm Password Field
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'confirmNewPassword'.tr,
                prefixIcon: const Icon(Icons.lock_open),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'pleaseConfirmPassword'.tr;
                }
                if (value != _newPasswordController.text) {
                  return 'passwordsDoNotMatch'.tr;
                }
                return null;
              },
              enabled: !_isLoading,
            ),
          ],
        ),
      ),
      actions: [
        ButtonX(
          onPressed: () => Navigator.pop(context),
          icon: Icons.cancel,
          label: 'cancel'.tr,
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
        ),
        SizedBox(
          height: 40,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _handleChangePassword,
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.lock_reset),
            label: Text(_isLoading ? 'changing'.tr : 'changePassword'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              disabledBackgroundColor: theme.colorScheme.primary.withOpacity(
                0.6,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

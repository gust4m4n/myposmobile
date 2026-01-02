import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../shared/widgets/dialog_x.dart';
import '../../shared/widgets/gray_button_x.dart';
import '../../shared/widgets/green_button_x.dart';
import '../../shared/widgets/text_field_x.dart';
import '../../shared/widgets/toast_x.dart';
import '../../translations/translation_extension.dart';
import '../services/change_password_service.dart';

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

    if (response.statusCode == 200) {
      // Clear form
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      // Close dialog and show success message
      if (mounted) {
        Navigator.pop(context);
        ToastX.success(context, 'passwordChangedSuccessfully'.tr);
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            TextFieldX(
              controller: _oldPasswordController,
              hintText: 'currentPassword'.tr,
              prefixIcon: Icons.lock,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureOldPassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureOldPassword = !_obscureOldPassword;
                  });
                },
              ),
              obscureText: _obscureOldPassword,
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
            TextFieldX(
              controller: _newPasswordController,
              hintText: 'newPassword'.tr,
              prefixIcon: Icons.lock_open,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
              ),
              obscureText: _obscureNewPassword,
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
            TextFieldX(
              controller: _confirmPasswordController,
              hintText: 'confirmNewPassword'.tr,
              prefixIcon: Icons.lock_open,
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
              obscureText: _obscureConfirmPassword,
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
        GrayButtonX(
          onClicked: () => Navigator.pop(context),
          title: 'cancel'.tr,
        ),
        GreenButtonX(
          onClicked: _handleChangePassword,
          title: _isLoading ? 'changing'.tr : 'changePassword'.tr,
          enabled: !_isLoading,
        ),
      ],
    );
  }
}

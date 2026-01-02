import 'package:flutter/material.dart';

import '../../shared/widgets/dialog_x.dart';
import '../../shared/widgets/gray_button_x.dart';
import '../../shared/widgets/green_button_x.dart';
import '../../shared/widgets/text_field_x.dart';
import '../../shared/widgets/toast_x.dart';
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
      ToastX.success(context, 'profileUpdatedSuccess'.tr);
      Navigator.of(context).pop(true); // Return true to indicate success
    } else {
      ToastX.error(context, response.message ?? 'profileUpdateFailed'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            TextFieldX(
              controller: _fullNameController,
              hintText: 'fullName'.tr,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'fullNameRequired'.tr;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email
            TextFieldX(
              controller: _emailController,
              hintText: 'email'.tr,
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
              child: GrayButtonX(
                onClicked: _isSubmitting
                    ? null
                    : () => Navigator.of(context).pop(),
                title: 'cancel'.tr,
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

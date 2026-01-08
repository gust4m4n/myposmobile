import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../shared/widgets/dialog_x.dart';
import '../../shared/widgets/gray_button_x.dart';
import '../../shared/widgets/green_button_x.dart';
import '../../shared/widgets/multiline_text_field_x.dart';
import '../../shared/widgets/text_field_x.dart';
import '../../shared/widgets/toast_x.dart';
import '../../translations/translation_extension.dart';
import '../services/categories_management_service.dart';

class AddCategoryDialog extends StatefulWidget {
  final String languageCode;

  const AddCategoryDialog({super.key, required this.languageCode});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isActive = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    TranslationService.setLanguage(widget.languageCode);

    if (kDebugMode) {
      _nameController.text =
          'Test Category ${DateTime.now().millisecondsSinceEpoch % 1000}';
      _descriptionController.text = 'Test category description';
      _isActive = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final service = CategoriesManagementService();
      final response = await service.createCategory(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        isActive: _isActive,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ToastX.success(context, 'categoryCreatedSuccess'.tr);
        Navigator.of(context).pop(true);
      } else {
        ToastX.error(context, response.message ?? 'categoryCreateFailed'.tr);
      }
    } catch (e) {
      if (!mounted) return;
      ToastX.error(context, 'categoryCreateFailed: $e');
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
      title: 'addCategory'.tr,
      width: 600,
      onClose: _isSubmitting ? null : () => Navigator.of(context).pop(),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              MultilineTextFieldX(
                controller: _descriptionController,
                hintText: '${'description'.tr} *',
                maxLines: 3,
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
        GrayButtonX(
          onClicked: _isSubmitting ? null : () => Navigator.of(context).pop(),
          title: 'cancel'.tr,
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

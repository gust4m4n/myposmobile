import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myposmobile/shared/widgets/gray_button_x.dart';

import '../../shared/widgets/dialog_x.dart';
import '../../shared/widgets/green_button_x.dart';
import '../../shared/widgets/multiline_text_field_x.dart';
import '../../shared/widgets/red_button_x.dart';
import '../../shared/widgets/text_field_x.dart';
import '../../shared/widgets/toast_x.dart';
import '../../translations/translation_extension.dart';
import '../models/category_model.dart';
import '../services/categories_management_service.dart';

class EditCategoryDialog extends StatefulWidget {
  final String languageCode;
  final CategoryModel category;

  const EditCategoryDialog({
    super.key,
    required this.languageCode,
    required this.category,
  });

  @override
  State<EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late bool _isActive;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    TranslationService.setLanguage(widget.languageCode);

    _nameController = TextEditingController(text: widget.category.name);
    _descriptionController = TextEditingController(
      text: widget.category.description ?? '',
    );
    _isActive = widget.category.isActive ?? true;

    if (kDebugMode) {
      _nameController.text =
          'Updated ${widget.category.name} ${DateTime.now().millisecondsSinceEpoch % 1000}';
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
      final response = await service.updateCategory(
        id: widget.category.id!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        isActive: _isActive,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ToastX.success(context, 'categoryUpdatedSuccess'.tr);
        Navigator.of(context).pop(true);
      } else {
        ToastX.error(context, response.message ?? 'categoryUpdateFailed'.tr);
      }
    } catch (e) {
      if (!mounted) return;
      ToastX.error(context, 'categoryUpdateFailed: $e');
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
      title: 'editCategory'.tr,
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
        RedButtonX(
          onClicked: _isSubmitting
              ? null
              : () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => DialogX(
                      title: 'deleteCategory'.tr,
                      content: Text(
                        '${'deleteCategoryConfirmation'.tr} "${widget.category.name}"?',
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
                      final service = CategoriesManagementService();
                      final response = await service.deleteCategory(
                        widget.category.id!,
                      );

                      if (!mounted) return;

                      if (response.statusCode == 200) {
                        ToastX.success(context, 'categoryDeletedSuccess'.tr);
                        Navigator.of(context).pop(true);
                      } else {
                        ToastX.error(
                          context,
                          response.message ?? 'categoryDeleteFailed'.tr,
                        );
                      }
                    } catch (e) {
                      if (!mounted) return;
                      ToastX.error(context, '${'categoryDeleteFailed'.tr}: $e');
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

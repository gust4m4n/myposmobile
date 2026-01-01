import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../shared/config/api_config.dart';
import '../../shared/utils/image_upload_service.dart';
import '../../shared/widgets/button_x.dart';
import '../../shared/widgets/dialog_x.dart';
import '../../shared/widgets/toast_x.dart';
import '../../translations/translation_extension.dart';

class UploadProfilePhotoDialog extends StatefulWidget {
  final String languageCode;
  final String? currentImageUrl;

  const UploadProfilePhotoDialog({
    super.key,
    required this.languageCode,
    this.currentImageUrl,
  });

  @override
  State<UploadProfilePhotoDialog> createState() =>
      _UploadProfilePhotoDialogState();
}

class _UploadProfilePhotoDialogState extends State<UploadProfilePhotoDialog> {
  File? _selectedFile;
  bool _isUploading = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    TranslationService.setLanguage(widget.languageCode);
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
        allowMultiple: false,
        dialogTitle: 'selectPhoto'.tr,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        if (kDebugMode) {
          print('📸 Selected file path: ${file.path}');
          print('📸 File exists: ${file.existsSync()}');
          print('📸 File size: ${file.lengthSync()} bytes');
        }

        setState(() {
          _selectedFile = file;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error picking image: $e');
      }
      if (mounted) {
        ToastX.error(context, '\${"failedToPickImage".tr}: \$e');
      }
    }
  }

  Future<void> _uploadPhoto() async {
    if (_selectedFile == null) return;

    if (kDebugMode) {
      print('📤 Starting upload for: ${_selectedFile!.path}');
    }

    setState(() {
      _isUploading = true;
    });

    final response = await ImageUploadService.uploadProfilePhoto(
      filePath: _selectedFile!.path,
    );

    if (!mounted) return;

    setState(() {
      _isUploading = false;
    });

    if (response.statusCode == 200) {
      ToastX.success(context, 'photoUploadedSuccess'.tr);
      Navigator.of(context).pop(true);
    } else {
      ToastX.error(context, response.message ?? 'photoUploadFailed'.tr);
    }
  }

  Future<void> _deletePhoto() async {
    if (widget.currentImageUrl == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DialogX(
        title: 'deletePhoto'.tr,
        content: Text('deletePhotoConfirmation'.tr),
        actions: [
          ButtonX(
            onPressed: () => Navigator.of(context).pop(false),
            label: 'cancel'.tr,
            backgroundColor: Colors.grey,
          ),
          ButtonX(
            onPressed: () => Navigator.of(context).pop(true),
            label: 'delete'.tr,
            backgroundColor: Colors.red,
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
    });

    final response = await ImageUploadService.deleteProfilePhoto();

    if (!mounted) return;

    setState(() {
      _isDeleting = false;
    });

    if (response.statusCode == 200) {
      ToastX.success(context, 'photoDeletedSuccess'.tr);
      Navigator.of(context).pop(true);
    } else {
      ToastX.error(context, response.message ?? 'photoDeleteFailed'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DialogX(
      title: 'profilePhoto'.tr,
      width: 500,
      onClose: () => Navigator.of(context).pop(),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Current or Selected Photo Preview
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: _selectedFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_selectedFile!, fit: BoxFit.cover),
                    )
                  : widget.currentImageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        '${ApiConfig.baseUrl}${widget.currentImageUrl}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 80,
                            color: theme.colorScheme.primary,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 80,
                      color: theme.colorScheme.primary,
                    ),
            ),
          ),
          const SizedBox(height: 24),

          // Pick Image Button
          if (_selectedFile == null)
            ButtonX(
              onPressed: _isUploading || _isDeleting ? null : _pickImage,
              icon: Icons.image,
              label: 'selectPhoto'.tr,
              backgroundColor: theme.colorScheme.primary,
            ),

          // Upload Button (shown when file selected)
          if (_selectedFile != null) ...[
            ButtonX(
              onPressed: _isUploading ? null : _uploadPhoto,
              icon: Icons.upload,
              label: _isUploading ? 'uploading'.tr : 'uploadPhoto'.tr,
              backgroundColor: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            ButtonX(
              onPressed: _isUploading
                  ? null
                  : () => setState(() => _selectedFile = null),
              icon: Icons.close,
              label: 'cancel'.tr,
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: theme.colorScheme.onSurface,
            ),
          ],

          // Delete Photo Button (shown when has current photo and no new selection)
          if (widget.currentImageUrl != null && _selectedFile == null) ...[
            const SizedBox(height: 12),
            ButtonX(
              onPressed: _isDeleting ? null : _deletePhoto,
              icon: Icons.delete,
              label: _isDeleting ? 'deleting'.tr : 'deletePhoto'.tr,
              backgroundColor: Colors.red,
            ),
          ],
        ],
      ),
    );
  }
}

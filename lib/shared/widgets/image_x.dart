import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ImageX extends StatelessWidget {
  final String? imageUrl;
  final String? baseUrl;
  final String? localImagePath; // Path to local file for preview
  final double size;
  final double cornerRadius;
  final Function(File) onPicked;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? iconColor;

  const ImageX({
    super.key,
    this.imageUrl,
    this.baseUrl,
    this.localImagePath,
    this.size = 80,
    this.cornerRadius = 40,
    required this.onPicked,
    this.isLoading = false,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        // Image Container
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color:
                backgroundColor ??
                theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(cornerRadius),
          ),
          child: localImagePath != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(cornerRadius),
                  child: Image.file(
                    File(localImagePath!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        size: size * 0.5,
                        color: iconColor ?? theme.colorScheme.primary,
                      );
                    },
                  ),
                )
              : imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(cornerRadius),
                  child: Image.network(
                    baseUrl != null ? '$baseUrl$imageUrl' : imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        size: size * 0.5,
                        color: iconColor ?? theme.colorScheme.primary,
                      );
                    },
                  ),
                )
              : Icon(
                  Icons.person,
                  size: size * 0.5,
                  color: iconColor ?? theme.colorScheme.primary,
                ),
        ),
        // Loading overlay
        if (isLoading)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(cornerRadius),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ),
        // Camera button
        Positioned(
          right: 4,
          bottom: 4,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: isLoading ? null : _handlePickImage,
              icon: Icon(Icons.camera_alt, size: size * 0.2 * 0.75),
              iconSize: size * 0.2,
              padding: EdgeInsets.all(size * 0.05),
              constraints: const BoxConstraints(),
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handlePickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final file = File(filePath);
        onPicked(file);
      }
    } catch (e) {
      // Error will be handled by parent
    }
  }
}

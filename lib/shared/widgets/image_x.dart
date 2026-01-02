import 'package:flutter/material.dart';

class ImageX extends StatelessWidget {
  final String? imageUrl;
  final String? baseUrl;
  final double size;
  final double cornerRadius;
  final VoidCallback onPicked;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? iconColor;

  const ImageX({
    super.key,
    this.imageUrl,
    this.baseUrl,
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
                backgroundColor ?? theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(cornerRadius),
          ),
          child: imageUrl != null
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
              color: Colors.black.withOpacity(0.5),
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
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(cornerRadius),
            ),
            child: IconButton(
              onPressed: isLoading ? null : onPicked,
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
}

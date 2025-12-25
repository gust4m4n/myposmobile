import 'package:flutter/material.dart';

class DialogX extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final VoidCallback? onClose;
  final double? width;

  const DialogX({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.onClose,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          if (onClose != null)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close, size: 20),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                iconSize: 20,
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
        ],
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      content: SizedBox(width: width ?? 600, child: content),
      actions: actions,
    );
  }
}

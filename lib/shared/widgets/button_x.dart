import 'package:flutter/material.dart';

class ButtonX extends StatelessWidget {
  final VoidCallback? onClicked;
  final String label;
  final Color backgroundColor;
  final Color? foregroundColor;

  const ButtonX({
    super.key,
    required this.onClicked,
    required this.label,
    required this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.0,
      child: ElevatedButton(
        onPressed: onClicked,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor ?? Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: Text(label),
      ),
    );
  }
}

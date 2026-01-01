import 'package:flutter/material.dart';

import 'button_x.dart';

class GreenButton extends StatelessWidget {
  final VoidCallback? onClicked;
  final String title;
  final bool enabled;

  const GreenButton({
    super.key,
    required this.onClicked,
    this.title = 'Button',
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ButtonX(
      onClicked: enabled ? onClicked : null,
      label: title,
      backgroundColor: Colors.green,
    );
  }
}

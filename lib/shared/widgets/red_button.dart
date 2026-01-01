import 'package:flutter/material.dart';

import 'button_x.dart';

class RedButton extends StatelessWidget {
  final VoidCallback? onClicked;
  final String title;
  final bool enabled;

  const RedButton({
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
      backgroundColor: Colors.red,
    );
  }
}

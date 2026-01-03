import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/theme_controller.dart';

/// Wrapper widget that provides gradient background for light mode
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => Container(
        decoration: BoxDecoration(
          gradient: themeController.isDarkMode.value
              ? null
              : themeController.lightGradient,
          color: themeController.isDarkMode.value
              ? Theme.of(context).scaffoldBackgroundColor
              : null,
        ),
        child: child,
      ),
    );
  }
}

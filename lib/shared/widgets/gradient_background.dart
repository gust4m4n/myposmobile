import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/theme_controller.dart';

/// Wrapper widget that provides consistent background for both light and dark modes
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: themeController.isDarkMode.value
              ? Theme.of(context).scaffoldBackgroundColor
              : themeController.lightBackgroundColor,
        ),
        child: child,
      ),
    );
  }
}

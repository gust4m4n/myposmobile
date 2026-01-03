import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/theme_controller.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => IconButton(
        icon: Icon(
          themeController.isDarkMode.value
              ? Icons.light_mode_rounded
              : Icons.dark_mode_rounded,
        ),
        onPressed: () => themeController.toggleTheme(),
        tooltip: themeController.isDarkMode.value ? 'Light Mode' : 'Dark Mode',
      ),
    );
  }
}

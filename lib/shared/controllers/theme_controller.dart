import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/storage_service.dart';

class ThemeController extends GetxController {
  late final Rx<bool> isDarkMode;

  ThemeController({bool initialIsDarkMode = true}) {
    isDarkMode = initialIsDarkMode.obs;
  }

  Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    final storage = await StorageService.getInstance();
    await storage.saveIsDarkMode(isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(
      0xFFF5F5F7,
    ), // Clean light gray background
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF007AFF), // iOS-style blue
      secondary: Color(0xFF34C759), // iOS-style green
      error: Color(0xFFFF3B30), // iOS-style red
      surface: Colors.white,
      onSurface: Color(0xFF1C1C1E),
      surfaceContainerHighest: Color(0xFFE5E5EA), // For elevated surfaces
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF1C1C1E),
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF1C1C1E)),
    ),
    cardColor: Colors.white,
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(0),
    ),
    dividerColor: const Color(0xFFE5E5EA),
    useMaterial3: true,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: _InstantPageTransitionsBuilder(),
        TargetPlatform.iOS: _InstantPageTransitionsBuilder(),
        TargetPlatform.linux: _InstantPageTransitionsBuilder(),
        TargetPlatform.macOS: _InstantPageTransitionsBuilder(),
        TargetPlatform.windows: _InstantPageTransitionsBuilder(),
      },
    ),
  );

  // Solid background color for light mode
  Color get lightBackgroundColor => const Color(0xFFF5F5F7);

  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF000000),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF0A84FF),
      secondary: Color(0xFF32D74B),
      error: Color(0xFFFF453A),
      surface: Color(0xFF1C1C1E),
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1C1C1E),
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardColor: const Color(0xFF1C1C1E),
    dividerColor: const Color(0xFF38383A),
    useMaterial3: true,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: _InstantPageTransitionsBuilder(),
        TargetPlatform.iOS: _InstantPageTransitionsBuilder(),
        TargetPlatform.linux: _InstantPageTransitionsBuilder(),
        TargetPlatform.macOS: _InstantPageTransitionsBuilder(),
        TargetPlatform.windows: _InstantPageTransitionsBuilder(),
      },
    ),
  );
}

// Custom page transition builder with no animation for instant navigation
class _InstantPageTransitionsBuilder extends PageTransitionsBuilder {
  const _InstantPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

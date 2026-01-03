import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/storage_service.dart';

class ThemeController extends GetxController {
  var isDarkMode = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final storage = await StorageService.getInstance();
    isDarkMode.value = storage.getIsDarkMode() ?? true;
  }

  Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    final storage = await StorageService.getInstance();
    await storage.saveIsDarkMode(isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0A84FF),
      secondary: Color(0xFF32D74B),
      error: Color(0xFFFF453A),
      surface: Colors.white,
      onSurface: Color(0xFF1C1C1E),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF1C1C1E),
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF1C1C1E)),
    ),
    cardColor: Colors.white,
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

  // Light mode gradient background colors (blue gradient like in attachment)
  LinearGradient get lightGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF5B9FE3), // Bright blue at top (more vibrant)
      Color(0xFF7EBCE6), // Medium blue
      Color(0xFF9DD4F5), // Light cyan blue at bottom
    ],
  );

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

import 'package:flutter/material.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

import 'pages/login_page.dart';
import 'pages/pos_home_page.dart';
import 'utils/http_client.dart';
import 'utils/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Initialize storage
  final storage = await StorageService.getInstance();

  // Restore window size or calculate 80% of screen
  final savedWidth = storage.getWindowWidth();
  final savedHeight = storage.getWindowHeight();

  double defaultWidth = 1200;
  double defaultHeight = 800;
  bool shouldCenter = true;

  if (savedWidth == null || savedHeight == null) {
    // Get screen size and calculate 80%
    final primaryDisplay = await screenRetriever.getPrimaryDisplay();
    defaultWidth = primaryDisplay.size.width * 0.8;
    defaultHeight = primaryDisplay.size.height * 0.8;
    shouldCenter = true;
  } else {
    defaultWidth = savedWidth;
    defaultHeight = savedHeight;
    shouldCenter = false;
  }

  WindowOptions windowOptions = WindowOptions(
    size: Size(defaultWidth, defaultHeight),
    minimumSize: const Size(400, 600),
    center: shouldCenter,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyPOSMobileApp());
}

class MyPOSMobileApp extends StatefulWidget {
  const MyPOSMobileApp({super.key});

  @override
  State<MyPOSMobileApp> createState() => _MyPOSMobileAppState();
}

class _MyPOSMobileAppState extends State<MyPOSMobileApp> with WindowListener {
  bool _isDarkMode = false;
  String _languageCode = 'id'; // Default to Indonesian
  String? _authToken;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _loadSavedData();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowResize() async {
    final size = await windowManager.getSize();
    final storage = await StorageService.getInstance();
    await storage.saveWindowSize(size.width, size.height);
  }

  Future<void> _loadSavedData() async {
    final storage = await StorageService.getInstance();
    final savedToken = storage.getToken();
    final savedLanguage = storage.getLanguageCode();
    final savedDarkMode = storage.getDarkMode();

    setState(() {
      _authToken = savedToken;
      _languageCode = savedLanguage;
      _isDarkMode = savedDarkMode;
      _isLoading = false;
    });

    // Set token to HttpClient if exists
    if (savedToken != null) {
      HttpClient().setAuthToken(savedToken);
    }
  }

  Future<void> _toggleTheme() async {
    final newDarkMode = !_isDarkMode;
    setState(() {
      _isDarkMode = newDarkMode;
    });

    // Save dark mode preference
    final storage = await StorageService.getInstance();
    await storage.saveDarkMode(newDarkMode);
  }

  Future<void> _toggleLanguage() async {
    final newLanguage = _languageCode == 'en' ? 'id' : 'en';
    setState(() {
      _languageCode = newLanguage;
    });

    // Save language preference
    final storage = await StorageService.getInstance();
    await storage.saveLanguageCode(newLanguage);
  }

  Future<void> _handleLoginSuccess(String token) async {
    setState(() {
      _authToken = token;
    });

    // Save token to storage
    final storage = await StorageService.getInstance();
    await storage.saveToken(token);
  }

  Future<void> _handleLogout() async {
    setState(() {
      _authToken = null;
    });

    // Clear token from storage and HttpClient
    final storage = await StorageService.getInstance();
    await storage.clearToken();
    HttpClient().clearAuthToken();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyPOSMobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey.shade50,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF007AFF),
          secondary: Color(0xFF34C759),
          error: Color(0xFFFF3B30),
          surface: Colors.white,
          onSurface: Colors.black87,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        cardColor: Colors.white,
        dividerColor: Colors.grey.shade200,
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
      ),
      darkTheme: ThemeData(
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
        dividerColor: Color(0xFF38383A),
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
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: _isLoading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _authToken == null
          ? LoginPage(
              isDarkMode: _isDarkMode,
              onThemeToggle: _toggleTheme,
              languageCode: _languageCode,
              onLanguageToggle: _toggleLanguage,
              onLoginSuccess: _handleLoginSuccess,
            )
          : POSHomePage(
              isDarkMode: _isDarkMode,
              onThemeToggle: _toggleTheme,
              languageCode: _languageCode,
              onLanguageToggle: _toggleLanguage,
              onLogout: _handleLogout,
            ),
    );
  }
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
    // Return child directly without any animation
    return child;
  }
}

import 'package:flutter/material.dart';

import 'pages/pos_home_page.dart';

void main() {
  runApp(const MyPOSMobileApp());
}

class MyPOSMobileApp extends StatefulWidget {
  const MyPOSMobileApp({super.key});

  @override
  State<MyPOSMobileApp> createState() => _MyPOSMobileAppState();
}

class _MyPOSMobileAppState extends State<MyPOSMobileApp> {
  bool _isDarkMode = false;
  String _languageCode = 'id'; // Default to Indonesian

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _toggleLanguage() {
    setState(() {
      _languageCode = _languageCode == 'en' ? 'id' : 'en';
    });
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
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: POSHomePage(
        isDarkMode: _isDarkMode,
        onThemeToggle: _toggleTheme,
        languageCode: _languageCode,
        onLanguageToggle: _toggleLanguage,
      ),
    );
  }
}

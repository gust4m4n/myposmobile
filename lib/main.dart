import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

import 'home/views/home_page.dart';
import 'login/views/login_page.dart';
import 'shared/controllers/auth_controller.dart';
import 'shared/controllers/language_controller.dart';
import 'shared/controllers/profile_controller.dart';
import 'shared/utils/api_x.dart';
import 'shared/utils/connectivity_service.dart';
import 'shared/utils/storage_service.dart';
import 'shared/widgets/connectivity_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Initialize GetX controllers
  Get.put(AuthController());
  Get.put(LanguageController());
  Get.put(ProfileController());

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

class _MyPOSMobileAppState extends State<MyPOSMobileApp>
    with WindowListener, WidgetsBindingObserver {
  final profileController = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    WidgetsBinding.instance.addObserver(this);

    // Initialize connectivity monitoring
    ConnectivityService().initialize();

    // Set navigator key for 401 handling
    ApiX.setNavigatorKey(Get.key);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    WidgetsBinding.instance.removeObserver(this);
    ConnectivityService().dispose();
    super.dispose();
  }

  @override
  void onWindowResize() async {
    final size = await windowManager.getSize();
    final storage = await StorageService.getInstance();
    await storage.saveWindowSize(size.width, size.height);
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final languageController = Get.find<LanguageController>();

    return Obx(
      () => GetMaterialApp(
        title: 'MyPOSMobile',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
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
        themeMode: ThemeMode.dark,
        home: authController.isLoading.value
            ? const Scaffold(body: Center(child: CircularProgressIndicator()))
            : ConnectivityWrapper(
                child: authController.isAuthenticated
                    ? HomePage(
                        languageCode: languageController.languageCode.value,
                      )
                    : LoginPage(
                        languageCode: languageController.languageCode.value,
                      ),
              ),
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

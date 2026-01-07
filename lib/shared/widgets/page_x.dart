import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/theme_controller.dart';
import 'app_bar_x.dart';

/// Reusable Page widget for consistent page structure across the application
class PageX extends StatelessWidget {
  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;
  final Widget? drawer;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Color? drawerScrimColor;
  final bool drawerEnableOpenDragGesture;
  final Widget? bottomNavigationBar;

  const PageX({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.leading,
    this.floatingActionButton,
    this.backgroundColor,
    this.bottom,
    this.drawer,
    this.scaffoldKey,
    this.drawerScrimColor,
    this.drawerEnableOpenDragGesture = true,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => Scaffold(
        key: scaffoldKey,
        backgroundColor: themeController.isDarkMode.value
            ? (backgroundColor ?? theme.scaffoldBackgroundColor)
            : (backgroundColor ?? theme.scaffoldBackgroundColor),
        appBar: title != null
            ? AppBarX(
                title: title!,
                leading: leading,
                actions: actions,
                bottom: bottom,
              )
            : null,
        body: body,
        floatingActionButton: floatingActionButton,
        drawer: drawer,
        drawerScrimColor: drawerScrimColor,
        drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}

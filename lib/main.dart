import 'package:flutter/material.dart';

import 'pages/pos_home_page.dart';

void main() {
  runApp(const MyPOSMobileApp());
}

class MyPOSMobileApp extends StatelessWidget {
  const MyPOSMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyPOSMobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const POSHomePage(),
    );
  }
}

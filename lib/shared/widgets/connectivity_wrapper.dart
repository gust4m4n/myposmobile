import 'package:flutter/material.dart';

import '../utils/connectivity_service.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  @override
  void initState() {
    super.initState();
    _listenToConnectivity();
  }

  void _listenToConnectivity() {
    ConnectivityService().connectivityStream.listen((isConnected) {
      if (mounted) {
        ConnectivityService.showConnectivitySnackbar(context, isConnected);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

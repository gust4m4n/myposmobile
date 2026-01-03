import 'package:flutter/material.dart';

import '../utils/connectivity_service.dart';

class ConnectivityIndicator extends StatefulWidget {
  const ConnectivityIndicator({super.key});

  @override
  State<ConnectivityIndicator> createState() => _ConnectivityIndicatorState();
}

class _ConnectivityIndicatorState extends State<ConnectivityIndicator> {
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _isConnected = ConnectivityService().isConnected;
    _listenToConnectivity();
  }

  void _listenToConnectivity() {
    ConnectivityService().connectivityStream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _isConnected ? 'Internet Connected' : 'No Internet Connection',
      child: Container(
        width: 12,
        height: 12,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isConnected ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}

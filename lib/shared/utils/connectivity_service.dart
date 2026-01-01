import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../widgets/toast_x.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  final _connectivityController = StreamController<bool>.broadcast();
  Stream<bool> get connectivityStream => _connectivityController.stream;

  void initialize() {
    // Check initial connectivity
    _checkConnectivity();

    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _updateConnectionStatus(results);
    });
  }

  Future<void> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      _isConnected = false;
      _connectivityController.add(false);
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;

    // Check if any result is not none
    _isConnected = results.any((result) => result != ConnectivityResult.none);

    // Only notify if status changed
    if (wasConnected != _isConnected) {
      _connectivityController.add(_isConnected);
      debugPrint(
        'Connectivity changed: ${_isConnected ? "Connected" : "Disconnected"}',
      );
    }
  }

  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }

  /// Show a snackbar when connectivity changes
  static void showConnectivitySnackbar(BuildContext context, bool isConnected) {
    final message = isConnected
        ? 'Internet connection restored'
        : 'No internet connection';

    if (isConnected) {
      ToastX.success(context, message);
    } else {
      ToastX.error(context, message);
    }
  }
}

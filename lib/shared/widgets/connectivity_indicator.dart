import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/offline_controller.dart';

class ConnectivityIndicator extends StatelessWidget {
  const ConnectivityIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final offlineController = Get.find<OfflineController>();
      final isConnected = offlineController.isOnline.value;

      String tooltipMessage;
      if (offlineController.isOfflineModeEnabled.value) {
        tooltipMessage = 'Offline Mode Enabled';
      } else {
        tooltipMessage = isConnected
            ? 'Internet Connected'
            : 'No Internet Connection';
      }

      return Tooltip(
        message: tooltipMessage,
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isConnected ? Colors.green : Colors.red,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      );
    });
  }
}

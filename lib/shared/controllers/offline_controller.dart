import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/offline_service.dart';
import '../utils/logger_x.dart';
import '../utils/storage_service.dart';

class OfflineController extends GetxController {
  final OfflineService _offlineService = Get.find<OfflineService>();

  // Observables
  RxBool get isOnline => _offlineService.isOnline;
  RxBool get isSyncing => _offlineService.isSyncing;
  RxInt get pendingSyncCount => _offlineService.pendingSyncCount;
  RxString get lastSyncTime => _offlineService.lastSyncTime;

  // Offline mode toggle - when enabled, forces app to work offline
  final RxBool isOfflineModeEnabled = false.obs;

  // Database stats
  final RxMap<String, dynamic> databaseStats = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadOfflineModeState();
    loadDatabaseStats();
  }

  // Load offline mode state from preferences
  Future<void> _loadOfflineModeState() async {
    try {
      final storage = await StorageService.getInstance();
      final savedState = storage.getOfflineMode();
      isOfflineModeEnabled.value = savedState;
      _offlineService.setOfflineMode(savedState);
      LoggerX.log('📱 Loaded offline mode state: $savedState');
    } catch (e) {
      LoggerX.log('❌ Error loading offline mode state: $e');
    }
  }

  // Load database statistics
  Future<void> loadDatabaseStats() async {
    try {
      final stats = await _offlineService.getDatabaseStats();
      databaseStats.value = stats;
    } catch (e) {
      LoggerX.log('❌ Error loading database stats: $e');
    }
  }

  // Toggle offline mode
  Future<void> toggleOfflineMode(bool value) async {
    isOfflineModeEnabled.value = value;
    _offlineService.setOfflineMode(value);

    // Save state to preferences
    try {
      final storage = await StorageService.getInstance();
      await storage.saveOfflineMode(value);
      LoggerX.log('💾 Saved offline mode state: $value');
    } catch (e) {
      LoggerX.log('❌ Error saving offline mode state: $e');
    }

    LoggerX.log('🔄 Offline mode ${value ? "enabled" : "disabled"}');
  }

  // Manual sync
  Future<void> syncNow() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final result = await _offlineService.manualSync();

      Get.back(); // Close loading dialog

      if (result['success']) {
        Get.snackbar(
          'Sync Berhasil',
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Sync Gagal',
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      await loadDatabaseStats();
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Download fresh data
  Future<void> downloadData() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final result = await _offlineService.downloadFreshData();

      Get.back();

      if (result['success']) {
        Get.snackbar(
          'Download Berhasil',
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Download Gagal',
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      await loadDatabaseStats();
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Clear all offline data
  Future<void> clearAllData() async {
    try {
      Get.dialog(
        AlertDialog(
          title: const Text('Hapus Semua Data'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus semua data offline? Data yang belum tersinkronisasi akan hilang.',
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
            TextButton(
              onPressed: () async {
                Get.back();

                Get.dialog(
                  const Center(child: CircularProgressIndicator()),
                  barrierDismissible: false,
                );

                await _offlineService.clearAllData();

                Get.back();

                Get.snackbar(
                  'Berhasil',
                  'Semua data offline telah dihapus',
                  snackPosition: SnackPosition.BOTTOM,
                );

                await loadDatabaseStats();
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Get status text
  String get statusText {
    if (isOnline.value) {
      return 'Online';
    } else {
      return 'Offline';
    }
  }

  // Get status color
  Color get statusColor {
    if (isOnline.value) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  // Get sync status text
  String get syncStatusText {
    if (isSyncing.value) {
      return 'Sedang Sinkronisasi...';
    } else if (pendingSyncCount.value > 0) {
      return '${pendingSyncCount.value} data belum tersinkronisasi';
    } else {
      return 'Semua data tersinkronisasi';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/controllers/offline_controller.dart';

class OfflineStatusWidget extends StatelessWidget {
  const OfflineStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OfflineController>();

    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: controller.statusColor.withAlpha((0.1 * 255).toInt()),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: controller.statusColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              controller.isOnline.value ? Icons.cloud_done : Icons.cloud_off,
              size: 16,
              color: controller.statusColor,
            ),
            const SizedBox(width: 6),
            Text(
              controller.statusText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: controller.statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OfflineSettingsPage extends StatelessWidget {
  const OfflineSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OfflineController());

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Offline Mode')),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          controller.isOnline.value
                              ? Icons.cloud_done
                              : Icons.cloud_off,
                          color: controller.statusColor,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status Koneksi',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                controller.statusText,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: controller.statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      Icons.sync,
                      'Status Sinkronisasi',
                      controller.syncStatusText,
                    ),
                    if (controller.lastSyncTime.value.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.access_time,
                        'Terakhir Disinkronkan',
                        _formatDateTime(controller.lastSyncTime.value),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Database Statistics Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistik Database',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildStatRow(
                      Icons.category,
                      'Kategori',
                      controller.databaseStats['categories_count']
                              ?.toString() ??
                          '0',
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      Icons.inventory_2,
                      'Produk',
                      controller.databaseStats['products_count']?.toString() ??
                          '0',
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      Icons.receipt,
                      'Pesanan',
                      controller.databaseStats['orders_count']?.toString() ??
                          '0',
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      Icons.pending,
                      'Menunggu Sync',
                      controller.databaseStats['pending_sync_count']
                              ?.toString() ??
                          '0',
                      valueColor: Colors.orange,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Actions Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aksi',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            controller.isOnline.value &&
                                !controller.isSyncing.value
                            ? () => controller.syncNow()
                            : null,
                        icon: controller.isSyncing.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.sync),
                        label: Text(
                          controller.isSyncing.value
                              ? 'Sedang Sinkronisasi...'
                              : 'Sinkronkan Sekarang',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed:
                            controller.isOnline.value &&
                                !controller.isSyncing.value
                            ? () => controller.downloadData()
                            : null,
                        icon: const Icon(Icons.download),
                        label: const Text('Download Data Terbaru'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => controller.loadDatabaseStats(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh Statistik'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => controller.clearAllData(),
                        icon: const Icon(Icons.delete_forever),
                        label: const Text('Hapus Semua Data'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Informasi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Data akan tersinkronisasi otomatis ketika koneksi tersedia\n'
                      '• Anda dapat tetap bekerja dalam mode offline\n'
                      '• Pastikan untuk melakukan sinkronisasi secara berkala\n'
                      '• Data yang belum tersinkronisasi akan hilang jika dihapus',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Baru saja';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes} menit yang lalu';
      } else if (difference.inDays < 1) {
        return '${difference.inHours} jam yang lalu';
      } else {
        return '${difference.inDays} hari yang lalu';
      }
    } catch (e) {
      return 'Tidak diketahui';
    }
  }
}

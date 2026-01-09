# Sync Integration Implementation Guide

## 📋 Overview

Implementasi sync integration untuk menghubungkan offline mode dengan backend API berdasarkan Postman collection terbaru.

## 🎯 Fitur yang Sudah Diimplementasikan

### 1. ✅ Sync Models
- **SyncUploadRequest** - Model untuk upload data ke server
- **SyncUploadResponse** - Model untuk response upload
- **SyncDownloadRequest** - Model untuk download data dari server
- **SyncDownloadResponse** - Model untuk response download
- **SyncStatusResponse** - Model untuk status sinkronisasi

### 2. ✅ Sync API Service
**File:** `lib/shared/services/sync_api_service.dart`

Endpoints yang sudah diimplementasikan:
- `POST /api/v1/sync/upload` - Upload data ke server
- `POST /api/v1/sync/download` - Download master data
- `GET /api/v1/sync/status` - Get sync status
- `GET /api/v1/sync/logs` - Get sync logs
- `POST /api/v1/sync/conflicts/resolve` - Resolve conflicts
- `GET /api/v1/sync/time` - Get server time

### 3. ✅ Sync Integration Service  
**File:** `lib/shared/services/sync_integration_service.dart`

Fungsi utama:
- `uploadDataToServer()` - Upload semua unsynced data
- `downloadDataFromServer()` - Download fresh data dari server
- `performFullSync()` - Full bidirectional sync
- `getSyncStatus()` - Check sync status
- Auto-convert antara offline models dan API format
- ID mapping untuk local/server synchronization

## 📦 Dependencies yang Ditambahkan

```yaml
device_info_plus: ^11.1.1  # Untuk mendapatkan unique device ID
```

## 🔧 Cara Penggunaan

### 1. Initialize Services

Di `main.dart`:

```dart
import 'package:myposmobile/shared/services/sync_integration_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  Get.put(OfflineService());
  Get.put(SyncIntegrationService());
  
  runApp(const MyApp());
}
```

### 2. Upload Data ke Server

```dart
final syncService = Get.find<SyncIntegrationService>();

try {
  final response = await syncService.uploadDataToServer();
  
  print('Uploaded: ${response.data.totalProcessed}');
  print('Failed: ${response.data.totalFailed}');
  
  if (response.data.hasConflicts) {
    print('Has conflicts that need resolution');
  }
  
  if (response.data.hasErrors) {
    print('Errors: ${response.data.errors}');
  }
} catch (e) {
  print('Upload failed: $e');
}
```

### 3. Download Data dari Server

```dart
final syncService = Get.find<SyncIntegrationService>();

try {
  final response = await syncService.downloadDataFromServer(
    entityTypes: ['categories', 'products'],
  );
  
  print('Downloaded: ${response.data.totalDownloaded} items');
  print('Has more: ${response.data.hasMore}');
} catch (e) {
  print('Download failed: $e');
}
```

### 4. Perform Full Sync

```dart
final syncService = Get.find<SyncIntegrationService>();

try {
  final result = await syncService.performFullSync();
  
  if (result['success']) {
    print('Uploaded: ${result['uploaded']}');
    print('Downloaded: ${result['downloaded']}');
  } else {
    print('Sync failed: ${result['error']}');
  }
} catch (e) {
  print('Full sync failed: $e');
}
```

### 5. Check Sync Status

```dart
final syncService = Get.find<SyncIntegrationService>();

try {
  final status = await syncService.getSyncStatus();
  
  print('Last sync: ${status.data.lastSyncAt}');
  print('Pending uploads: ${status.data.pendingUploads}');
  print('Pending downloads: ${status.data.pendingDownloads}');
  print('Is syncing: ${status.data.isSyncing}');
} catch (e) {
  print('Failed to get status: $e');
}
```

## 🔄 Integration dengan OfflineService

Update `OfflineService` untuk menggunakan SyncIntegrationService:

```dart
class OfflineService extends GetxController {
  // Add sync integration service
  late final SyncIntegrationService _syncIntegrationService;
  
  @override
  void onInit() {
    super.onInit();
    _syncIntegrationService = Get.find<SyncIntegrationService>();
    _initConnectivity();
    _listenToConnectivityChanges();
  }
  
  // Update syncAll method
  Future<Map<String, dynamic>> syncAll() async {
    if (!isOnline.value) {
      return {'success': false, 'message': 'No internet connection'};
    }

    if (isSyncing.value) {
      return {'success': false, 'message': 'Sync already in progress'};
    }

    isSyncing.value = true;
    
    try {
      // Use sync integration service
      final result = await _syncIntegrationService.performFullSync();
      
      lastSyncTime.value = result['sync_timestamp'] ?? DateTime.now().toIso8601String();
      await _updatePendingSyncCount();
      
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Sync failed: $e'};
    } finally {
      isSyncing.value = false;
    }
  }
}
```

## 📊 Data Flow

### Upload Flow:
```
Local SQLite DB → Offline Services → SyncIntegrationService 
→ API Format Conversion → SyncApiService → Backend API
→ Server ID Mapping → Update Local DB
```

### Download Flow:
```
Backend API → SyncApiService → SyncIntegrationService
→ Model Conversion → Offline Services → Local SQLite DB
```

## 🧪 Testing

### 1. Test Upload
```dart
// Ensure you have unsynced data
final productService = ProductOfflineService();
await productService.saveProduct(testProduct);

// Upload
final syncService = Get.find<SyncIntegrationService>();
final response = await syncService.uploadDataToServer();

// Verify
expect(response.data.processedProducts, greaterThan(0));
expect(response.data.productMapping, isNotEmpty);
```

### 2. Test Download
```dart
final syncService = Get.find<SyncIntegrationService>();
final response = await syncService.downloadDataFromServer(
  entityTypes: ['products'],
);

// Verify data is saved locally
final productService = ProductOfflineService();
final products = await productService.getAllProducts();
expect(products, isNotEmpty);
```

### 3. Test Full Sync
```dart
final syncService = Get.find<SyncIntegrationService>();
final result = await syncService.performFullSync();

expect(result['success'], isTrue);
expect(result['uploaded'], greaterThanOrEqualTo(0));
expect(result['downloaded'], greaterThanOrEqualTo(0));
```

## ⚠️ Important Notes

1. **Device ID**: Unique per device, digunakan untuk tracking sync
2. **Timestamp**: Always use ISO 8601 format untuk consistency
3. **Local ID Mapping**: Format: `{type}_{local_id}` (e.g., `cat_1`, `prod_25`)
4. **Error Handling**: Always wrap API calls dalam try-catch
5. **Batch Processing**: Sync queue diproses dalam batch (100 items)
6. **Conflict Resolution**: Conflicts perlu di-handle manual saat ini

## 🔮 Future Enhancements

1. **Automatic Conflict Resolution** - Smart merge strategies
2. **Partial Sync** - Sync only specific entities
3. **Background Sync** - Periodic auto-sync
4. **Retry Mechanism** - Auto-retry failed syncs
5. **Compression** - Compress large payloads
6. **Encryption** - Encrypt sensitive data during sync
7. **Delta Sync** - Only sync changed fields
8. **Offline Queue Optimization** - Priority-based queue

## 📝 API Response Codes

- `0` - Success
- `1001` - Validation error
- `1002` - Authentication error
- `1003` - Authorization error
- `1004` - Not found
- `1005` - Conflict detected
- `5000` - Internal server error

## 🎨 UI Integration

Lihat `offline_status_widget.dart` dan `offline_controller.dart` untuk contoh UI integration yang bisa ditambahkan:

- Sync button with progress indicator
- Last sync timestamp display
- Pending sync count badge
- Conflict resolution UI
- Sync logs viewer

---

**Status:** ✅ Ready for Integration
**Last Updated:** 2026-01-09
**Version:** 1.0.0

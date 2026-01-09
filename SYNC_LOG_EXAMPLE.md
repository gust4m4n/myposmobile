# Sync Log Display Example

## Full Sync Process Output

Ketika `performFullSync()` dipanggil, sistem akan menampilkan log detail seperti berikut:

```
🚀 Starting full sync...
🕐 Server time: 2026-01-09T10:30:45.123Z

⬆️  Uploading local changes...
✅ Upload complete: 5 items processed

⬇️  Downloading data from server...
🏢 Saving 3 tenants...
✅ Tenants saved successfully
🏪 Saving 12 branches...
✅ Branches saved successfully
👥 Saving 45 users...
✅ Users saved successfully
📁 Saving 18 categories...
✅ Categories saved successfully
📦 Saving 250 products...
✅ Products saved successfully

============================================================
📊 FULL SYNC COMPLETED SUCCESSFULLY
============================================================
📥 Downloaded and Saved to Local DB:
   🏢 Tenants:       3 records
   🏪 Branches:     12 records
   👥 Users:        45 records
   📁 Categories:   18 records
   📦 Products:    250 records
   📋 Orders:        0 records
   ─────────────────────────────────
   📊 Total:       328 records

📤 Uploaded to Server:
   ✅ Processed: 5
   ❌ Failed:    0
============================================================
```

## Detail Implementasi

### 1. **Automatic Sync on Login**
```dart
// lib/login/services/login_controller.dart
final syncService = Get.find<SyncIntegrationService>();
final result = await syncService.performFullSync();

if (result['success']) {
  print('✅ Sync complete: ${result['total_saved']} records saved');
  print('📊 Breakdown: ${result['saved_counts']}');
}
```

### 2. **Manual Sync Trigger**
```dart
// From any page with sync button
final syncService = Get.find<SyncIntegrationService>();
final result = await syncService.performFullSync();

// Result contains:
// - success: bool
// - total_saved: int (total records saved)
// - saved_counts: Map<String, int> (breakdown per entity)
// - uploaded: int (items uploaded to server)
// - failed: int (failed uploads)
// - has_conflicts: bool
// - sync_timestamp: String
```

### 3. **Sync Result Structure**
```dart
{
  'success': true,
  'total_saved': 328,
  'saved_counts': {
    'tenants': 3,
    'branches': 12,
    'users': 45,
    'categories': 18,
    'products': 250,
    'orders': 0
  },
  'uploaded': 5,
  'downloaded': 328,
  'failed': 0,
  'has_conflicts': false,
  'sync_timestamp': '2026-01-09T10:30:45.123Z'
}
```

## Logging per Entity

### Tenants
```
🏢 Saving 3 tenants...
✅ Tenants saved successfully
```

### Branches
```
🏪 Saving 12 branches...
✅ Branches saved successfully
```

### Users
```
👥 Saving 45 users...
✅ Users saved successfully
```

### Categories
```
📁 Saving 18 categories...
✅ Categories saved successfully
```

### Products
```
📦 Saving 250 products...
✅ Products saved successfully
```

### Error Handling
```
🏪 Saving 12 branches...
❌ Error saving branches: Connection timeout
Stack trace: ...
```

## Keuntungan Logging Detail

1. **Visibility** - User dapat melihat progress sync secara real-time
2. **Debugging** - Error handling dengan stack trace untuk troubleshooting
3. **Metrics** - Mengetahui jumlah exact data yang di-sync per entity
4. **Verification** - Confirm bahwa semua entity berhasil disimpan ke local DB
5. **Performance** - Monitor waktu yang dibutuhkan per entity

## Integration Points

### 1. Login Flow
```dart
// Automatic sync after successful login
await syncService.performFullSync();
// Log will display automatically in console
```

### 2. Manual Sync Button
```dart
// User triggers sync manually
FloatingActionButton(
  onPressed: () async {
    final result = await syncService.performFullSync();
    
    if (result['success']) {
      Get.snackbar(
        'Sync Complete',
        '${result['total_saved']} records synced successfully',
      );
    }
  },
  child: Icon(Icons.sync),
)
```

### 3. Background Sync
```dart
// Periodic background sync
Timer.periodic(Duration(minutes: 15), (timer) async {
  if (await connectivity.isConnected) {
    await syncService.performFullSync();
    // Logs will show each sync iteration
  }
});
```

## Offline Service Integration

Semua offline services sudah terintegrasi:
- ✅ `TenantOfflineService` - Save tenants to local DB
- ✅ `BranchOfflineService` - Save branches to local DB
- ✅ `UserOfflineService` - Save users to local DB
- ✅ `CategoryOfflineService` - Save categories to local DB
- ✅ `ProductOfflineService` - Save products to local DB
- 🚧 `OrderOfflineService` - Orders sync (placeholder ready)

## Console Output Format

```
[2026-01-09 10:30:45] 🚀 Starting full sync...
[2026-01-09 10:30:45] 🕐 Server time: 2026-01-09T10:30:45.123Z
[2026-01-09 10:30:46] ⬆️  Uploading local changes...
[2026-01-09 10:30:47] ✅ Upload complete: 5 items processed
[2026-01-09 10:30:47] ⬇️  Downloading data from server...
[2026-01-09 10:30:48] 🏢 Saving 3 tenants...
[2026-01-09 10:30:48] ✅ Tenants saved successfully
[2026-01-09 10:30:48] 🏪 Saving 12 branches...
[2026-01-09 10:30:49] ✅ Branches saved successfully
[2026-01-09 10:30:49] 👥 Saving 45 users...
[2026-01-09 10:30:50] ✅ Users saved successfully
[2026-01-09 10:30:50] 📁 Saving 18 categories...
[2026-01-09 10:30:51] ✅ Categories saved successfully
[2026-01-09 10:30:51] 📦 Saving 250 products...
[2026-01-09 10:30:53] ✅ Products saved successfully
[2026-01-09 10:30:53] 
============================================================
📊 FULL SYNC COMPLETED SUCCESSFULLY
============================================================
📥 Downloaded and Saved to Local DB:
   🏢 Tenants:       3 records
   🏪 Branches:     12 records
   👥 Users:        45 records
   📁 Categories:   18 records
   📦 Products:    250 records
   📋 Orders:        0 records
   ─────────────────────────────────
   📊 Total:       328 records

📤 Uploaded to Server:
   ✅ Processed: 5
   ❌ Failed:    0
============================================================

[2026-01-09 10:30:53] ✅ Full sync completed in 8.2 seconds
```

# Status Sync - Full Sync Implementation

## Current Sync Behavior

Ketika `performFullSync()` dipanggil, sistem akan:

### 1. Upload ke Server (Unsynced Data)
- ✅ **Categories** - Upload unsynced categories ke server
- ✅ **Products** - Upload unsynced products ke server
- ✅ **Orders** - Upload unsynced orders ke server

### 2. Download dari Server (Fresh Data)
Request mencakup **SEMUA** entity types:
- ✅ **Categories** - Downloaded & saved to local DB
- ✅ **Products** - Downloaded & saved to local DB
- ⏳ **Orders** - Downloaded but not saved yet (needs implementation)
- ⏳ **Tenants** - Downloaded but not saved (no offline service yet)
- ⏳ **Branches** - Downloaded but not saved (no offline service yet)
- ⏳ **Users** - Downloaded but not saved (no offline service yet)

## Entity Sync Support Matrix

| Entity | Upload | Download | Save to Local DB | Auto-Sync |
|--------|--------|----------|------------------|-----------|
| **Categories** | ✅ | ✅ | ✅ | ✅ |
| **Products** | ✅ | ✅ | ✅ | ✅ |
| **Orders** | ✅ | ✅ | ⏳ Not yet | ❌ No wrapper |
| **Tenants** | ❌ No offline | ✅ | ❌ No offline | ❌ API only |
| **Branches** | ❌ No offline | ✅ | ❌ No offline | ❌ API only |
| **Users** | ❌ No offline | ✅ | ❌ No offline | ❌ API only |

## Implementation Details

### Full Sync Flow

```dart
performFullSync() {
  1. Get server time reference
  2. Upload unsynced data:
     - Categories (unsynced)
     - Products (unsynced)
     - Orders (unsynced)
  3. Download fresh data for ALL entities:
     - categories ✅
     - products ✅
     - orders ✅ (requested)
     - tenants ✅ (requested)
     - branches ✅ (requested)
     - users ✅ (requested)
  4. Save downloaded data to local DB:
     - Categories: Saved ✅
     - Products: Saved ✅
     - Others: Skipped (no offline service)
}
```

### Auto-Sync Trigger

Auto-sync terpicu oleh:
- ProductService.saveProduct() ✅
- ProductService.updateProduct() ✅
- ProductService.deleteProduct() ✅
- ProductService.updateStock() ✅
- CategoryService.saveCategory() ✅
- CategoryService.updateCategory() ✅
- CategoryService.deleteCategory() ✅

Delay: 500ms setelah operasi, non-blocking

## Next Steps untuk Complete Sync

### Priority 1: Orders
1. Implement saving downloaded orders to local DB
2. Create OrderService wrapper dengan auto-sync
3. Update order-related UI to use OrderService

### Priority 2: Master Data (Lower Priority)
Tenants, Branches, Users biasanya tidak perlu offline-first karena:
- Data tidak sering berubah
- Perlu authentication/authorization dari server
- Lebih aman langsung dari server

Jika diperlukan offline support:
1. Create TenantOfflineService, BranchOfflineService, UserOfflineService
2. Create service wrappers dengan auto-sync
3. Update sync integration untuk save downloaded data

## Code Location

- **Sync Integration**: `lib/shared/services/sync_integration_service.dart`
- **Sync API**: `lib/shared/services/sync_api_service.dart`
- **Product Service**: `lib/products/services/product_service.dart`
- **Category Service**: `lib/categories/services/category_service.dart`

## Testing Sync

```dart
// Manual trigger full sync
final syncService = Get.find<SyncIntegrationService>();
final result = await syncService.performFullSync();

print('Sync result: $result');
// Expected output:
// {
//   'success': true,
//   'uploaded': 5,
//   'downloaded': 100,
//   'failed': 0,
//   'has_conflicts': false,
//   'sync_timestamp': '2026-01-09T10:30:00.000Z'
// }
```

## Summary

✅ **WORKING NOW:**
- Categories: Full offline-first dengan auto-sync
- Products: Full offline-first dengan auto-sync
- Server download request: Includes ALL entity types

⏳ **NEEDS WORK:**
- Saving downloaded orders to local DB
- OrderService wrapper dengan auto-sync
- Optional: Offline services untuk Tenants/Branches/Users

🎯 **RECOMMENDATION:**
Focus on completing Orders sync support first, karena ini critical untuk POS functionality. Master data (Tenants/Branches/Users) bisa tetap API-only untuk security dan simplicity.

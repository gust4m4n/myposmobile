# Offline-First Architecture dengan Auto-Sync

## Overview
Aplikasi menggunakan **offline-first architecture** dimana semua data disimpan di **local SQLite database** dan otomatis sync ke server ketika online.

## Entity yang Dikelola
- ✅ **Products** - ProductService (with auto-sync) ← **READY TO USE**
- ✅ **Categories** - CategoryService (with auto-sync) ← **READY TO USE**
- ⚠️ **Tenants** - TenantsService (API only, no offline)
- ⚠️ **Branches** - BranchesService (API only, no offline)
- ⚠️ **Users** - UsersService (API only, no offline)
- ⚠️ **Orders** - OrderOfflineService (offline only, belum ada wrapper dengan auto-sync)
- ⚠️ **Audit Trails** - AuditTrailService (API only untuk compliance)

## Cara Kerja

### 1. Read Operations (SELECT)
```dart
// Load dari local DB - instant, no network needed
final products = await ProductService().getAllProducts();
final categories = await CategoryService().getActiveCategories();
```

### 2. Write Operations (INSERT/UPDATE/DELETE)
```dart
// Save ke local DB dulu, lalu auto-sync di background
final productService = ProductService();

// Create
await productService.saveProduct(newProduct); // ← Auto-sync triggered

// Update
await productService.updateProduct(updatedProduct); // ← Auto-sync triggered

// Delete
await productService.deleteProduct(productId); // ← Auto-sync triggered

// Update stock
await productService.updateStock(productId, newStock); // ← Auto-sync triggered
```

### 3. Manual Sync
```dart
// Force sync sekarang (blocking)
await ProductService().syncNow();

// Check unsynced count
final unsyncedCount = await ProductService().getUnsyncedCount();
```

## Benefits

### ✅ Offline-First
- App tetap berfungsi tanpa internet
- Data selalu available dari local DB
- UI tidak freeze waiting for network

### ✅ Auto-Sync
- Perubahan otomatis sync ke server
- Background sync - tidak blocking UI
- Retry mechanism untuk sync failures

### ✅ Performance
- Instant data loading (no network latency)
- Reduced server load
- Better user experience

## Migration Guide

### Before (Old Way - Direct API Call)
```dart
// ❌ Old: Direct API call - slow, requires internet
final response = await ProductApiService().getProducts();
if (response.statusCode == 200) {
  setState(() {
    products = response.data;
  });
}
```

### After (New Way - Offline-First)
```dart
// ✅ New: Load from local DB - instant
final products = await ProductService().getAllProducts();
setState(() {
  this.products = products;
});
```

## Implementation Examples

### ProductsWidget
```dart
class _ProductsWidgetState extends State<ProductsWidget> {
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load dari local DB - instant!
    final categories = await _categoryService.getAllCategories();
    final products = await _productService.getAllProducts();
    
    setState(() {
      _categories = categories;
      _products = products;
    });
  }
}
```

### Create/Update/Delete dengan Auto-Sync
```dart
// Create
final newProduct = ProductModel(
  name: 'Nasi Goreng',
  price: 25000,
  categoryId: 1,
);
await _productService.saveProduct(newProduct);
// ↑ Saved to local DB + auto-sync triggered

// Update
product.price = 30000;
await _productService.updateProduct(product);
// ↑ Updated in local DB + auto-sync triggered

// Delete
await _productService.deleteProduct(productId);
// ↑ Deleted from local DB + auto-sync triggered
```

## Sync Queue System

Setiap write operation akan:
1. **Save to local DB** (instant)
2. **Add to sync queue** (pending_sync table)
3. **Trigger background sync** (non-blocking)
4. **Mark as synced** (after successful upload)

Jika sync gagal (offline/error):
- Data tetap aman di local DB
- Akan di-retry pada sync berikutnya
- User tetap bisa bekerja normal

## Best Practices

### ✅ DO
- Gunakan `ProductService` bukan `ProductOfflineService` langsung
- Load data dari local DB untuk display
- Biarkan auto-sync handle sync ke server
- Gunakan `syncNow()` hanya jika really necessary

### ❌ DON'T
- Jangan langsung panggil API untuk read operations
- Jangan manual manage sync queue
- Jangan blocking UI untuk sync operations

## Troubleshooting

### Data tidak sync ke server?
```dart
// Check unsynced count
final count = await ProductService().getUnsyncedCount();
print('Unsynced products: $count');

// Force sync
await ProductService().syncNow();
```

### Data tidak update di UI?
```dart
// Pastikan reload dari local DB setelah sync
await _productService.syncNow();
await _loadData(); // Refresh UI
```

## File Structure

```
lib/
├── products/
│   └── services/
│       ├── product_service.dart          ← ✅ Use this (with auto-sync)
│       └── product_offline_service.dart  ← Low-level DB operations
├── categories/
│   └── services/
│       ├── category_service.dart         ← ✅ Use this (with auto-sync)
│       └── category_offline_service.dart ← Low-level DB operations
├── tenants/
│   └── services/
│       └── tenants_service.dart          ← ⚠️ API only (no offline)
├── branches/
│   └── services/
│       └── branches_service.dart         ← ⚠️ API only (no offline)
├── users/
│   └── services/
│       └── users_service.dart            ← ⚠️ API only (no offline)
├── orders/
│   └── services/
│       └── order_offline_service.dart    ← ⚠️ Offline only (no auto-sync wrapper yet)
├── audit-trails/
│   └── services/
│       └── audit_trail_service.dart      ← ⚠️ API only (direct to server)
└── shared/
    └── services/
        └── sync_integration_service.dart ← Sync orchestrator
```

## Status Implementation

**✅ COMPLETED & READY:**
- ProductService with auto-sync
- CategoryService with auto-sync

**⚠️ NEEDS WORK:**
- Tenants, Branches, Users - Need offline service layer + wrapper
- Orders - Has offline service, needs auto-sync wrapper
- Audit Trails - Currently API only, decide if needs offline

## Next Steps

1. ✅ **COMPLETED** - ProductService with auto-sync
2. ✅ **COMPLETED** - CategoryService with auto-sync
3. ⏳ **TODO** - Create offline service layers for Tenants, Branches, Users
4. ⏳ **TODO** - Create OrderService wrapper dengan auto-sync
5. ⏳ **TODO** - Update UI components untuk gunakan services yang sudah siap
6. ⏳ **TODO** - Test offline → online sync workflow

## Summary

**Offline-First Architecture sekarang tersedia untuk 2 entity:**
- Products ✅
- Categories ✅

**Pattern yang sudah di-implement:**
1. Load data dari local DB (instant, no network)
2. Create/Update/Delete di local DB dulu
3. Auto-sync di background (500ms delay)
4. Silent fail jika offline (retry later)
5. Manual syncNow() tersedia jika perlu force sync

**Selanjutnya:** 
- Gunakan ProductService dan CategoryService yang sudah ready
- Untuk entity lain (Tenants, Branches, Users, Orders), gunakan service yang ada sementara waktu
- Tambahkan offline layer secara bertahap jika diperlukan

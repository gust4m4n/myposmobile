# Quick Start Guide - Offline-First Services

## ⚠️ Status: Partial Implementation

Saat ini hanya **ProductService** dan **CategoryService** yang telah di-implement dengan offline-first + auto-sync.

## Setup (Sudah Dikonfigurasi)

Services sudah terdaftar di `main.dart`:
```dart
Get.put(ProductService());  // ✅ Ready
Get.put(CategoryService()); // ✅ Ready
```

## Cara Penggunaan

### 1. Import Service yang Dibutuhkan

```dart
import 'package:get/get.dart';
// Atau langsung import service:
import '../../products/services/product_service.dart';
import '../../categories/services/category_service.dart';
```

### 2. Akses Service via GetX

```dart
class MyWidget extends StatelessWidget {
  final ProductService _productService = Get.find<ProductService>();
  final CategoryService _categoryService = Get.find<CategoryService>();
  
  // ... rest of your code
}
```

### 3. Read Operations (Instant dari Local DB)

```dart
// ✅ Products (READY)
final products = await Get.find<ProductService>().getAllProducts();
final activeProducts = await Get.find<ProductService>().getActiveProducts();
final product = await Get.find<ProductService>().getProductById(1);

// ✅ Categories (READY)
final categories = await Get.find<CategoryService>().getAllCategories();
final activeCategories = await Get.find<CategoryService>().getActiveCategories();

// ⚠️ For other entities, use API services directly:
// - TenantsService (API only)
// - BranchesService (API only)
// - UsersService (API only)
// - OrderOfflineService (offline only, no auto-sync yet)
```

### 4. Write Operations (Auto-Sync)

```dart
// CREATE - Save to local DB + auto-sync in background
final productService = Get.find<ProductService>();
await productService.saveProduct(newProduct); // ← Auto-sync triggered

// UPDATE - Update local DB + auto-sync in background  
await productService.updateProduct(updatedProduct); // ← Auto-sync triggered

// DELETE - Delete from local DB + auto-sync in background
await productService.deleteProduct(productId); // ← Auto-sync triggered

// SPECIAL OPERATIONS
await productService.updateStock(productId, newStock); // ← Auto-sync triggered
await Get.find<OrderService>().updateOrderStatus(orderId, 'completed'); // ← Auto-sync triggered
```

### 5. Manual Sync (Jika Diperlukan)

```dart
// Force sync sekarang (blocking)
await Get.find<ProductService>().syncNow();

// Check jumlah data yang belum sync
final unsyncedCount = await Get.find<ProductService>().getUnsyncedCount();
print('Unsynced products: $unsyncedCount');
```

## Contoh Lengkap: Product Management Widget

```dart
class ProductsWidget extends StatefulWidget {
  @override
  State<ProductsWidget> createState() => _ProductsWidgetState();
}

class _ProductsWidgetState extends State<ProductsWidget> {
  final ProductService _productService = Get.find<ProductService>();
  final CategoryService _categoryService = Get.find<CategoryService>();
  
  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Load from local DB - instant!
      final products = await _productService.getAllProducts();
      final categories = await _categoryService.getActiveCategories();
      
      if (mounted) {
        setState(() {
          _products = products;
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProduct(ProductModel product) async {
    try {
      // Save to local DB first, then auto-sync
      await _productService.saveProduct(product);
      
      // Reload data to show changes
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product saved and syncing...')),
        );
      }
    } catch (e) {
      print('Error saving product: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteProduct(int productId) async {
    try {
      // Delete from local DB first, then auto-sync
      await _productService.deleteProduct(productId);
      
      // Reload data to show changes
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product deleted and syncing...')),
        );
      }
    } catch (e) {
      print('Error deleting product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return ListTile(
          title: Text(product.name),
          subtitle: Text('Stock: ${product.stock}'),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _deleteProduct(product.id!),
          ),
        );
      },
    );
  }
}
```

## Available Services

| Entity | Service | Key Methods |
|--------|---------|-------------|
| **Products** | `ProductService` | `getAllProducts()`, `saveProduct()`, `updateProduct()`, `deleteProduct()`, `updateStock()` |
| **Categories** | `CategoryService` | `getAllCategories()`, `getActiveCategories()`, `saveCategory()`, `updateCategory()`, `deleteCategory()` |
| **Tenants** | `TenantService` | `getAllTenants()`, `getActiveTenants()`, `saveTenant()`, `updateTenant()`, `deleteTenant()` |
| **Branches** | `BranchService` | `getAllBranches()`, `getBranchesByTenant()`, `saveBranch()`, `updateBranch()`, `deleteBranch()` |
| **Users** | `UserService` | `getAllUsers()`, `getUserByEmail()`, `saveUser()`, `updateUser()`, `deleteUser()` |
| **Orders** | `OrderService` | `getAllOrders()`, `getTodayOrders()`, `saveOrder()`, `updateOrderStatus()`, `updatePaymentStatus()` |

## Tips
Status | Key Methods |
|--------|---------|--------|-------------|
| **Products** | `ProductService` | ✅ **READY** | `getAllProducts()`, `saveProduct()`, `updateProduct()`, `deleteProduct()`, `updateStock()` |
| **Categories** | `CategoryService` | ✅ **READY** | `getAllCategories()`, `getActiveCategories()`, `saveCategory()`, `updateCategory()`, `deleteCategory()` |
| **Tenants** | `TenantsService` | ⚠️ API Only | Gunakan API service langsung (no offline yet) |
| **Branches** | `BranchesService` | ⚠️ API Only | Gunakan API service langsung (no offline yet) |
| **Users** | `UsersService` | ⚠️ API Only | Gunakan API service langsung (no offline yet) |
| **Orders** | `OrderOfflineService` | ⚠️ Offline Only | Has offline, needs auto-sync wrapper
- Jangan panggil API langsung untuk read operations
- Jangan manual manage sync queue
- Jangan blocking UI untuk sync operations
- Jangan lupa handle errors dengan try-catch

## Auto-Sync Behavior

- **Delay**: 500ms setelah write operation
- **Non-blocking**: Background operation, tidak freeze UI
- **Silent fail**: Jika offline atau error, akan retry di sync berikutnya
- **Bidirectional**: Upload unsynced + download fresh data dari server

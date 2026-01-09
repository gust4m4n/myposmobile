# SQLite Offline Mode - Setup Guide

## 📦 Dependencies yang Ditambahkan

Berikut adalah dependencies yang telah ditambahkan ke `pubspec.yaml`:

```yaml
sqflite: ^2.3.3+1          # SQLite plugin untuk Flutter
sqflite_common_ffi: ^2.3.3  # FFI support untuk desktop (macOS)
path: ^1.9.0                # Path manipulation
```

## 🗄️ Struktur Database

Database SQLite telah dikonfigurasi dengan tabel-tabel berikut:

### 1. **Categories**
Menyimpan data kategori produk
- Fields: id, tenant_id, name, description, image, is_active, timestamps, sync status

### 2. **Products**
Menyimpan data produk
- Fields: id, name, price, category_id, description, sku, stock, is_active, image, sync status

### 3. **Orders**
Menyimpan data pesanan
- Fields: id, order_number, tenant_id, branch_id, user_id, customer info, totals, payment info, timestamps, sync status

### 4. **Order Items**
Menyimpan detail item pesanan
- Fields: id, order_id, product_id, product_name, quantity, price, subtotal, notes

### 5. **Sync Queue**
Menyimpan antrian sinkronisasi
- Fields: id, table_name, record_id, operation, data, created_at, retry_count, last_error

### 6. **Sync Metadata**
Menyimpan metadata sinkronisasi
- Fields: key, value, updated_at

## 📁 File yang Dibuat

### 1. Database Helper
**Location:** `lib/shared/database/database_helper.dart`
- Inisialisasi dan manajemen database SQLite
- Support untuk macOS menggunakan FFI
- Database migration handling
- Transaction support

### 2. Offline Services

#### Category Offline Service
**Location:** `lib/categories/services/category_offline_service.dart`
- CRUD operations untuk categories
- Search dan filter categories
- Sync queue management

#### Product Offline Service
**Location:** `lib/products/services/product_offline_service.dart`
- CRUD operations untuk products
- Stock management
- Search dan filter products
- Low stock tracking

#### Order Offline Service
**Location:** `lib/orders/services/order_offline_service.dart`
- Create dan manage orders
- Order items management
- Sales summary
- Date range filtering

### 3. Offline Service (Main Controller)
**Location:** `lib/shared/services/offline_service.dart`
- Connectivity monitoring
- Auto-sync when online
- Manual sync operations
- Database statistics

### 4. Offline Controller
**Location:** `lib/shared/controllers/offline_controller.dart`
- GetX controller untuk offline functionality
- UI state management
- User actions handling

### 5. Offline Status Widget
**Location:** `lib/shared/widgets/offline_status_widget.dart`
- Status indicator widget
- Offline settings page
- Database statistics display

## 🚀 Cara Menggunakan

### 1. Install Dependencies

Jalankan command berikut:
```bash
flutter pub get
```

### 2. Initialize Offline Service

Tambahkan di `main.dart`:

```dart
import 'package:myposmobile/shared/services/offline_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize offline service
  Get.put(OfflineService());
  
  runApp(const MyApp());
}
```

### 3. Gunakan Offline Status Widget

Tambahkan widget di AppBar atau tempat yang sesuai:

```dart
import 'package:myposmobile/shared/widgets/offline_status_widget.dart';

AppBar(
  title: Text('Dashboard'),
  actions: [
    OfflineStatusWidget(),
    SizedBox(width: 16),
  ],
)
```

### 4. Akses Offline Settings Page

```dart
import 'package:myposmobile/shared/widgets/offline_status_widget.dart';

// Navigate to settings
Get.to(() => OfflineSettingsPage());
```

### 5. Contoh Penggunaan Service

#### Menyimpan Product ke Offline
```dart
final productService = ProductOfflineService();

// Save single product
await productService.saveProduct(product);

// Save multiple products
await productService.saveProducts(productList);

// Get all products
final products = await productService.getAllProducts();

// Search products
final results = await productService.searchProducts('query');
```

#### Membuat Order Offline
```dart
final orderService = OrderOfflineService();

// Create order
final order = OrderOfflineModel(
  orderNumber: 'ORD-20260109-001',
  totalAmount: 100000,
  grandTotal: 100000,
  paymentMethod: 'cash',
  paymentStatus: 'paid',
  orderStatus: 'completed',
  createdAt: DateTime.now().toIso8601String(),
  items: [
    OrderItemOfflineModel(
      orderId: 0, // Will be set after insert
      productId: 1,
      productName: 'Product 1',
      quantity: 2,
      price: 50000,
      subtotal: 100000,
    ),
  ],
);

await orderService.createOrder(order);
```

#### Sinkronisasi Data
```dart
final offlineService = Get.find<OfflineService>();

// Manual sync
final result = await offlineService.syncAll();

// Check sync status
final needsSync = await offlineService.needsSync();

// Get database stats
final stats = await offlineService.getDatabaseStats();
```

## 🔄 Auto Sync

Service akan otomatis:
- Monitor status koneksi internet
- Melakukan auto-sync ketika kembali online
- Track pending sync count
- Process sync queue

## 📊 Database Statistics

Anda dapat melihat statistik database:
- Jumlah categories
- Jumlah products
- Jumlah orders
- Pending sync count
- Database path

## ⚠️ Important Notes

1. **Desktop Support**: Database menggunakan `sqflite_common_ffi` untuk support macOS/Windows/Linux
2. **Sync Queue**: Semua perubahan data akan masuk ke sync queue untuk di-sync ke server
3. **Transaction Safety**: Order creation menggunakan database transaction untuk data integrity
4. **Index Optimization**: Database sudah menggunakan index untuk performa query yang lebih baik

## 🔧 Next Steps

1. **Implementasi API Integration**
   - Update `OfflineService._processSyncQueue()` dengan actual API calls
   - Implement `downloadFreshData()` untuk download data dari server

2. **Update Existing Services**
   - Modify existing services untuk menggunakan offline service
   - Implement fallback ke offline data ketika offline

3. **Error Handling**
   - Add proper error handling
   - Implement retry mechanism

4. **Testing**
   - Test offline mode functionality
   - Test sync mechanism
   - Test data integrity

## 📝 Example Integration

Contoh integrasi dengan existing product service:

```dart
class ProductService {
  final ProductOfflineService _offlineService = ProductOfflineService();
  final OfflineService _offline = Get.find<OfflineService>();

  Future<List<ProductModel>> getProducts() async {
    if (_offline.isOnline.value) {
      try {
        // Try to get from API
        final response = await http.get(...);
        final products = parseProducts(response);
        
        // Save to offline database
        await _offlineService.saveProducts(products);
        
        return products;
      } catch (e) {
        // Fallback to offline data
        return await _offlineService.getAllProducts();
      }
    } else {
      // Use offline data
      return await _offlineService.getAllProducts();
    }
  }
}
```

## 🎯 Features

✅ SQLite database setup dengan FFI support untuk desktop
✅ Complete CRUD operations untuk Categories, Products, Orders
✅ Connectivity monitoring dengan auto-sync
✅ Sync queue management
✅ Database statistics dan monitoring
✅ Offline status indicator widget
✅ Comprehensive offline settings page
✅ Transaction support untuk data integrity
✅ Index optimization untuk performa

## 🛠️ Troubleshooting

Jika terjadi error saat running:

1. **Clean build**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **macOS Permissions**
   Pastikan app memiliki permission untuk file access

3. **Database Path Issues**
   Database akan disimpan di application documents directory

---

**Ready to use!** 🚀

Database SQLite untuk offline mode sudah siap digunakan. Silakan integrasikan dengan existing services Anda.

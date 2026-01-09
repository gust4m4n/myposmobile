# Product API - Analisis Perubahan & Status

## ✅ Status: SUDAH KOMPATIBEL!

Model dan service yang ada **sudah sesuai** dengan struktur API terbaru dari Postman.

---

## 📊 Perubahan API Product

### **1. Struktur Response Product - Updated**

**Response Baru** (sekarang):
```json
{
  "id": 223,
  "tenant_id": 17,
  "name": "Nasi Goreng Spesial",
  "description": "Nasi goreng dengan telur, ayam, dan sayuran",
  "category_id": 17,
  "category_detail": {              // ⭐ NESTED OBJECT
    "id": 17,
    "name": "Main Course",
    "description": "Menu makanan utama",
    "image": null
  },
  "sku": "FOOD-001",
  "price": 25000,
  "stock": 47,
  "image": "/uploads/products/product_223.jpg",
  "is_active": true,
  "created_at": "2025-12-25 10:00:00",
  "updated_at": "2026-01-09 10:30:00"
}
```

**Response Lama** (deprecated):
```json
{
  "id": 50,
  "tenant_id": 18,
  "name": "Kemeja Batik Pria",
  "category": "Pakaian Pria",          // ❌ STRING (dihapus)
  "sku": "FASHION-001",
  "price": 250000,
  "stock": 30,
  "is_active": true
}
```

### **2. Perubahan Field**

| Field Old | Field New | Status |
|-----------|-----------|--------|
| `category` (string) | ❌ **DIHAPUS** | Deprecated |
| - | `category_id` (int) | ✅ **BARU** |
| - | `category_detail` (object) | ✅ **BARU** |
| `description` | `description` | ✅ Sama |
| `sku` | `sku` | ✅ Sama |
| `price` | `price` | ✅ Sama |
| `stock` | `stock` | ✅ Sama |
| `image` | `image` | ✅ Sama |
| `is_active` | `is_active` | ✅ Sama |

---

## 📱 Status Model & Service

### **ProductModel** (`lib/home/models/product_model.dart`)

✅ **SUDAH KOMPATIBEL!**

```dart
class ProductModel {
  final int? id;
  final String name;
  final double price;
  final int? categoryId;                           // ✅ Ada
  final Map<String, dynamic>? categoryDetail;      // ✅ Ada
  final String? description;
  final String? sku;
  final int? stock;
  final bool? isActive;
  final String? image;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      categoryId: json['category_id'] as int?,
      categoryDetail: json['category_detail'] as Map<String, dynamic>?,
      // ... fields lainnya
    );
  }
}
```

### **ProductOfflineService** (`lib/products/services/product_offline_service.dart`)

✅ **SUDAH KOMPATIBEL!**

```dart
// Save product - handle category_detail as JSON
Future<int> saveProduct(ProductModel product) async {
  final data = {
    'category_id': product.categoryId,
    'category_detail': product.categoryDetail != null
        ? jsonEncode(product.categoryDetail)  // ✅ Encode to JSON string
        : null,
    // ... fields lainnya
  };
  // ...
}

// Map to product - parse category_detail from JSON
ProductModel _mapToProduct(Map<String, dynamic> map) {
  return ProductModel(
    categoryId: map['category_id'] as int?,
    categoryDetail: map['category_detail'] != null
        ? jsonDecode(map['category_detail'] as String)  // ✅ Decode JSON
        : null,
    // ...
  );
}
```

### **SyncIntegrationService** (`lib/shared/services/sync_integration_service.dart`)

✅ **SUDAH KOMPATIBEL!**

```dart
// Upload format - menggunakan category_id
Map<String, dynamic> _productToUploadFormat(ProductModel product) {
  return {
    'category_id': product.categoryId,  // ✅ Kirim category_id
    'name': product.name,
    'price': product.price,
    'stock': product.stock,
    // ...
  };
}

// Download - ProductModel.fromJson akan handle category_detail
final products = data.products!
    .map((prod) => ProductModel.fromJson(prod as Map<String, dynamic>))
    .toList();
await _productService.saveProducts(products);  // ✅ Auto-save category_detail
```

---

## 🔄 API Endpoints Products

### **1. List Products**
```
GET /api/v1/products?page=1&page_size=32&search=ayam
```
- ✅ Pagination support
- ✅ Search by name/description/SKU
- ✅ Returns category_detail nested object

### **2. List Products by Category**
```
GET /api/v1/products/by-category/{category_id}?page=1&page_size=20
```
- ✅ Filter by category_id
- ✅ Pagination support

### **3. Get Product by ID**
```
GET /api/v1/products/{id}
```
- ✅ Returns full product with category_detail

### **4. Create Product**
```
POST /api/v1/products
{
  "name": "Produk Baru",
  "description": "Deskripsi",
  "category_id": 13,     // ✅ Gunakan category_id
  "sku": "SKU-001",
  "price": 50000,
  "stock": 100,
  "is_active": true
}
```

### **5. Update Product**
```
PUT /api/v1/products/{id}
{
  "name": "Produk Updated",
  "category_id": 13,      // ✅ Gunakan category_id
  "price": 75000,
  "stock": 150,
  "is_active": true
}
```

### **6. Delete Product**
```
DELETE /api/v1/products/{id}
```

### **7. Upload Product Image**
```
POST /api/v1/products/{id}/photo
Content-Type: multipart/form-data
Field: image (file)
```
- Max size: 5MB
- Formats: jpg, jpeg, png, gif, webp

### **8. Delete Product Image**
```
DELETE /api/v1/products/{id}/photo
```

---

## ⚠️ Stock Management

**PENTING**: Tidak ada endpoint terpisah untuk stock management!

❌ Endpoint ini **TIDAK ADA**:
- `/products/{id}/stock`
- `/products/{id}/increase-stock`
- `/products/{id}/decrease-stock`

✅ Stock dikelola melalui:
1. **Update Product API** - update field `stock` langsung
2. **Create Order** - otomatis kurangi stock saat order dibuat

```dart
// Offline Mode - stock management lokal
await productService.updateStock(productId, newStock);
await productService.decreaseStock(productId, quantity);

// Sync ke server - akan update melalui sync endpoint
await syncService.uploadDataToServer();
```

---

## 📝 Database Schema (SQLite)

✅ **SUDAH SESUAI!**

```sql
CREATE TABLE products (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  price REAL NOT NULL,
  category_id INTEGER,              -- ✅ Menyimpan category_id
  category_detail TEXT,             -- ✅ JSON string dari category_detail
  description TEXT,
  sku TEXT,
  stock INTEGER,
  is_active INTEGER DEFAULT 1,
  image TEXT,
  synced INTEGER DEFAULT 0,
  last_synced_at TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
```

---

## ✅ Yang Sudah Berfungsi

1. ✅ ProductModel support `category_id` dan `category_detail`
2. ✅ ProductOfflineService encode/decode `category_detail` as JSON
3. ✅ SyncIntegrationService upload dengan `category_id`
4. ✅ SyncIntegrationService download & parse `category_detail`
5. ✅ Database schema support `category_detail` as TEXT (JSON)
6. ✅ CRUD operations (Create, Read, Update, Delete)
7. ✅ Stock management lokal (update, decrease)
8. ✅ Search & filter products
9. ✅ Low stock detection
10. ✅ Sync queue untuk unsynced changes

---

## 🎯 Kesimpulan

### **STATUS: TIDAK PERLU UPDATE! ✅**

Semua komponen sudah kompatibel dengan struktur API terbaru:
- ✅ Model mendukung `category_id` + `category_detail`
- ✅ Offline service handle JSON encode/decode
- ✅ Sync service kirim `category_id`, terima `category_detail`
- ✅ Database schema sudah sesuai

### **Next Steps (Opsional)**

Jika ingin enhance functionality:

1. **Product Image Management**
   - Implementasi upload/delete image melalui API
   - Cache images untuk offline mode
   - Sync images dengan server

2. **Advanced Stock Management**
   - Stock history tracking
   - Low stock notifications
   - Bulk stock updates

3. **Category Integration**
   - Display category name dari `category_detail`
   - Filter products by multiple categories
   - Category-based statistics

---

## 📚 File References

- Model: `lib/home/models/product_model.dart`
- Offline Service: `lib/products/services/product_offline_service.dart`
- Sync Service: `lib/shared/services/sync_integration_service.dart`
- Management Service: `lib/products/services/products_management_service.dart`
- API Service: `lib/home/services/products_service.dart`
- Database Helper: `lib/shared/database/database_helper.dart`

---

**Last Updated**: January 9, 2026  
**API Version**: v1  
**Compatibility**: ✅ 100%

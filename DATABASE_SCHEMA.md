# Database Schema - MyPOS Mobile

## Overview
Local SQLite database untuk offline-first architecture dengan 10 tables utama.

Database Version: **2**
Database File: `mypos_offline.db`

---

## Tables

### 1. **tenants**
Menyimpan data tenant/perusahaan.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY | Server tenant ID |
| name | TEXT | NOT NULL | Nama tenant |
| email | TEXT | | Email tenant |
| phone | TEXT | | No telepon |
| address | TEXT | | Alamat lengkap |
| city | TEXT | | Kota |
| province | TEXT | | Provinsi |
| postal_code | TEXT | | Kode pos |
| logo | TEXT | | URL/path logo |
| is_active | INTEGER | DEFAULT 1 | Status aktif (1=aktif, 0=nonaktif) |
| created_at | TEXT | | Timestamp created |
| updated_at | TEXT | | Timestamp updated |
| synced | INTEGER | DEFAULT 0 | Status sinkronisasi (0=belum, 1=sudah) |
| last_synced_at | TEXT | | Timestamp last sync |

**Indexes:**
- `idx_tenants_active` ON (is_active)

---

### 2. **branches**
Menyimpan data cabang dari tenant.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY | Server branch ID |
| tenant_id | INTEGER | FK → tenants | ID tenant |
| name | TEXT | NOT NULL | Nama cabang |
| code | TEXT | | Kode cabang |
| address | TEXT | | Alamat lengkap |
| city | TEXT | | Kota |
| province | TEXT | | Provinsi |
| postal_code | TEXT | | Kode pos |
| phone | TEXT | | No telepon |
| email | TEXT | | Email cabang |
| is_active | INTEGER | DEFAULT 1 | Status aktif |
| created_at | TEXT | | Timestamp created |
| updated_at | TEXT | | Timestamp updated |
| created_by | INTEGER | | User ID creator |
| created_by_name | TEXT | | Nama creator |
| updated_by | INTEGER | | User ID updater |
| updated_by_name | TEXT | | Nama updater |
| synced | INTEGER | DEFAULT 0 | Status sinkronisasi |
| last_synced_at | TEXT | | Timestamp last sync |

**Indexes:**
- `idx_branches_tenant` ON (tenant_id)
- `idx_branches_active` ON (is_active)

---

### 3. **users**
Menyimpan data pengguna/kasir.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY | Server user ID |
| tenant_id | INTEGER | FK → tenants | ID tenant |
| branch_id | INTEGER | FK → branches | ID cabang |
| name | TEXT | NOT NULL | Nama user |
| email | TEXT | UNIQUE, NOT NULL | Email unik |
| phone | TEXT | | No telepon |
| role | TEXT | | Role user (admin, cashier, etc) |
| is_active | INTEGER | DEFAULT 1 | Status aktif |
| created_at | TEXT | | Timestamp created |
| updated_at | TEXT | | Timestamp updated |
| created_by | INTEGER | | User ID creator |
| created_by_name | TEXT | | Nama creator |
| updated_by | INTEGER | | User ID updater |
| updated_by_name | TEXT | | Nama updater |
| synced | INTEGER | DEFAULT 0 | Status sinkronisasi |
| last_synced_at | TEXT | | Timestamp last sync |

**Indexes:**
- `idx_users_tenant` ON (tenant_id)
- `idx_users_branch` ON (branch_id)
- `idx_users_email` ON (email)

---

### 4. **categories**
Menyimpan data kategori produk.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY | Server category ID |
| tenant_id | INTEGER | | ID tenant |
| name | TEXT | NOT NULL | Nama kategori |
| description | TEXT | | Deskripsi kategori |
| image | TEXT | | URL/path gambar |
| is_active | INTEGER | DEFAULT 1 | Status aktif |
| created_at | TEXT | | Timestamp created |
| updated_at | TEXT | | Timestamp updated |
| created_by | INTEGER | | User ID creator |
| created_by_name | TEXT | | Nama creator |
| updated_by | INTEGER | | User ID updater |
| updated_by_name | TEXT | | Nama updater |
| synced | INTEGER | DEFAULT 0 | Status sinkronisasi |
| last_synced_at | TEXT | | Timestamp last sync |

**Indexes:**
- `idx_categories_tenant` ON (tenant_id)

---

### 5. **products**
Menyimpan data produk.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY | Server product ID |
| name | TEXT | NOT NULL | Nama produk |
| price | REAL | NOT NULL | Harga produk |
| category_id | INTEGER | FK → categories | ID kategori |
| description | TEXT | | Deskripsi produk |
| sku | TEXT | | SKU/kode produk |
| stock | INTEGER | | Jumlah stok |
| is_active | INTEGER | DEFAULT 1 | Status aktif |
| image | TEXT | | URL/path gambar |
| category_detail | TEXT | | JSON category detail |
| synced | INTEGER | DEFAULT 0 | Status sinkronisasi |
| last_synced_at | TEXT | | Timestamp last sync |

**Indexes:**
- `idx_products_category` ON (category_id)
- `idx_products_synced` ON (synced)

---

### 6. **orders**
Menyimpan data order/transaksi.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | Local order ID |
| order_number | TEXT | UNIQUE | Nomor order unik |
| tenant_id | INTEGER | | ID tenant |
| branch_id | INTEGER | | ID cabang |
| user_id | INTEGER | | ID user/kasir |
| customer_name | TEXT | | Nama customer |
| customer_phone | TEXT | | No telp customer |
| total_amount | REAL | NOT NULL | Total sebelum diskon/tax |
| discount | REAL | DEFAULT 0 | Jumlah diskon |
| tax | REAL | DEFAULT 0 | Jumlah pajak |
| grand_total | REAL | NOT NULL | Total akhir |
| payment_method | TEXT | | Metode pembayaran |
| payment_status | TEXT | | Status pembayaran |
| order_status | TEXT | | Status order |
| notes | TEXT | | Catatan order |
| created_at | TEXT | NOT NULL | Timestamp created |
| updated_at | TEXT | | Timestamp updated |
| synced | INTEGER | DEFAULT 0 | Status sinkronisasi |
| last_synced_at | TEXT | | Timestamp last sync |
| server_id | INTEGER | | ID dari server setelah sync |

**Indexes:**
- `idx_orders_tenant` ON (tenant_id)
- `idx_orders_branch` ON (branch_id)
- `idx_orders_user` ON (user_id)
- `idx_orders_synced` ON (synced)
- `idx_orders_created_at` ON (created_at)

---

### 7. **order_items**
Menyimpan detail item per order.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | Local item ID |
| order_id | INTEGER | NOT NULL, FK → orders | ID order |
| product_id | INTEGER | NOT NULL, FK → products | ID produk |
| product_name | TEXT | NOT NULL | Nama produk (snapshot) |
| quantity | INTEGER | NOT NULL | Jumlah qty |
| price | REAL | NOT NULL | Harga per unit (snapshot) |
| subtotal | REAL | NOT NULL | Total (qty × price) |
| notes | TEXT | | Catatan item |
| synced | INTEGER | DEFAULT 0 | Status sinkronisasi |

**Indexes:**
- `idx_order_items_order` ON (order_id)

**Foreign Keys:**
- ON DELETE CASCADE: Hapus items jika order dihapus

---

### 8. **payments**
Menyimpan data pembayaran.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | Local payment ID |
| order_id | INTEGER | NOT NULL, FK → orders | ID order |
| tenant_id | INTEGER | FK → tenants | ID tenant |
| branch_id | INTEGER | FK → branches | ID cabang |
| user_id | INTEGER | FK → users | ID user/kasir |
| amount | REAL | NOT NULL | Jumlah pembayaran |
| payment_method | TEXT | NOT NULL | Metode (cash, card, qris, etc) |
| payment_status | TEXT | DEFAULT 'pending' | Status (pending, paid, failed) |
| reference_number | TEXT | | No referensi (untuk non-cash) |
| notes | TEXT | | Catatan pembayaran |
| paid_at | TEXT | | Timestamp paid |
| created_at | TEXT | NOT NULL | Timestamp created |
| updated_at | TEXT | | Timestamp updated |
| synced | INTEGER | DEFAULT 0 | Status sinkronisasi |
| last_synced_at | TEXT | | Timestamp last sync |
| server_id | INTEGER | | ID dari server setelah sync |

**Indexes:**
- `idx_payments_order` ON (order_id)
- `idx_payments_synced` ON (synced)

**Foreign Keys:**
- ON DELETE CASCADE: Hapus payment jika order dihapus

---

### 9. **sync_queue**
Queue untuk tracking data yang perlu disinkronisasi ke server.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | Queue ID |
| table_name | TEXT | NOT NULL | Nama table (orders, payments, etc) |
| record_id | INTEGER | NOT NULL | ID record yang perlu sync |
| operation | TEXT | NOT NULL | Operasi (create, update, delete) |
| data | TEXT | | JSON data untuk sync |
| created_at | TEXT | NOT NULL | Timestamp queued |
| retry_count | INTEGER | DEFAULT 0 | Jumlah retry |
| last_error | TEXT | | Error message terakhir |

**Indexes:**
- `idx_sync_queue_table` ON (table_name)

---

### 10. **sync_metadata**
Metadata untuk sinkronisasi (last sync timestamps, etc).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| key | TEXT | PRIMARY KEY | Metadata key |
| value | TEXT | | Metadata value |
| updated_at | TEXT | | Timestamp updated |

---

## Database Operations

### Initialization
```dart
final dbHelper = DatabaseHelper();
final db = await dbHelper.database;
```

### Get Database Info
```dart
final info = await dbHelper.getDatabaseInfo();
print('Tenants: ${info['tenants_count']}');
print('Branches: ${info['branches_count']}');
print('Users: ${info['users_count']}');
print('Categories: ${info['categories_count']}');
print('Products: ${info['products_count']}');
print('Orders: ${info['orders_count']}');
print('Payments: ${info['payments_count']}');
print('Pending Sync: ${info['pending_sync_count']}');
```

### Clear All Data
```dart
await dbHelper.clearAllData();
```

### Transaction
```dart
await dbHelper.transaction((txn) async {
  await txn.insert('orders', orderData);
  await txn.insert('order_items', itemData);
});
```

---

## Migration Strategy

### Version 1 → 2
- Added tables: `tenants`, `branches`, `users`, `payments`
- Added indexes untuk foreign keys
- Added indexes untuk performance optimization

### Upgrade Process
Otomatis handle upgrade melalui `_onUpgrade()` method dengan:
- CREATE TABLE IF NOT EXISTS untuk tabel baru
- CREATE INDEX IF NOT EXISTS untuk index baru
- Preserve existing data

---

## Best Practices

### 1. Offline-First
- Semua operasi CREATE/UPDATE/DELETE ke local DB dulu
- Tambahkan ke `sync_queue` untuk upload nanti
- Set `synced = 0` untuk tracking

### 2. Data Integrity
- Gunakan transactions untuk operasi multi-table
- Foreign key constraints untuk relational integrity
- Cascade delete untuk cleanup otomatis

### 3. Performance
- Indexes pada frequently queried columns
- Pagination untuk large datasets
- Clean up synced data secara berkala

### 4. Sync Management
- Retry mechanism untuk failed sync
- Conflict resolution strategy
- Timestamp tracking untuk sync status

---

## Entity Relationships

```
tenants (1) ─┬─ (n) branches
             ├─ (n) users
             └─ (n) categories

branches (1) ─┬─ (n) users
              ├─ (n) orders
              └─ (n) payments

users (1) ─┬─ (n) orders
           └─ (n) payments

categories (1) ── (n) products

products (1) ── (n) order_items

orders (1) ─┬─ (n) order_items
            └─ (n) payments
```

---

## Storage Size Estimates

Per 1000 records:
- Tenants: ~100 KB
- Branches: ~150 KB
- Users: ~120 KB
- Categories: ~80 KB
- Products: ~200 KB
- Orders: ~300 KB
- Order Items: ~150 KB
- Payments: ~180 KB
- Sync Queue: ~250 KB

Total estimate for typical usage:
- Small: < 10 MB (< 1000 orders)
- Medium: 10-50 MB (1000-5000 orders)
- Large: 50-200 MB (5000-20000 orders)

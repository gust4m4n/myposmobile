# API Structure Update Analysis

## 📋 Ringkasan Perubahan API

Berdasarkan Postman collection terbaru, berikut adalah endpoint dan struktur API yang perlu disesuaikan:

### ✅ Endpoint Baru yang Perlu Diimplementasikan:

#### 1. **Sync (Offline Mode)** - 🆕 MAJOR FEATURE
- `POST /api/v1/sync/upload` - Upload data dari client
- `POST /api/v1/sync/download` - Download master data
- `GET /api/v1/sync/status` - Get sync status
- `GET /api/v1/sync/logs` - Get sync logs
- `POST /api/v1/sync/conflicts/resolve` - Resolve conflicts
- `GET /api/v1/sync/time` - Get server time

#### 2. **PIN Management** - 🆕 NEW FEATURE
- `POST /api/v1/pin/create` - Create PIN
- `POST /api/v1/pin/change` - Change PIN
- `GET /api/v1/pin/check` - Check PIN status
- `POST /api/v1/pin/admin-change` - Admin change PIN

#### 3. **Audit Trails** - 🆕 NEW FEATURE
- `GET /api/v1/audit-trails` - List audit trails
- `GET /api/v1/audit-trails/{id}` - Get audit trail by ID
- `GET /api/v1/audit-trails/entity/{table}/{id}` - Get entity audit history
- `GET /api/v1/audit-trails/user/{userId}` - Get user activity log

#### 4. **Profile Management** - 🔄 UPDATED
- `GET /api/v1/profile` - Get profile
- `POST /api/v1/profile/change-password` - Change password
- `POST /api/v1/profile/admin-change-password` - Admin change password
- `PUT /api/v1/profile` - Update profile
- `POST /api/v1/profile/image` - Upload profile image
- `DELETE /api/v1/profile/image` - Delete profile image

### 📊 Struktur Response API

#### Health Check Response
```json
{
  "code": 0,
  "message": "Status retrieved successfully",
  "data": {
    "status": "ok",
    "version": "1.0.0",
    "startup_time": "2026-01-01 10:30:45",
    "uptime": "5 days, 3 hours, 25 minutes, 42 seconds",
    "uptime_details": {
      "days": 5,
      "hours": 3,
      "minutes": 25,
      "seconds": 42
    },
    "system": {
      "hostname": "server-01",
      "os": "darwin",
      "architecture": "arm64",
      "go_version": "go1.21.0",
      "cpu_cores": 8
    },
    "resources": {
      "goroutines": 12,
      "memory": {
        "allocated_mb": "45.23",
        "total_alloc_mb": "128.45",
        "system_mb": "72.56",
        "gc_cycles": 15
      }
    },
    "database": {
      "status": "connected",
      "version": "PostgreSQL 15.3...",
      "pool": {
        "max_open_connections": 0,
        "open_connections": 2,
        "in_use": 0,
        "idle": 2,
        "wait_count": 0,
        "wait_duration": "0s"
      }
    },
    "server": {
      "port": "8080",
      "environment": "development"
    }
  }
}
```

#### Sync Upload Request
```json
{
  "client_id": "device_uuid_12345",
  "client_timestamp": "2026-01-09T10:30:00Z",
  "users": [...],
  "products": [...],
  "categories": [...],
  "orders": [...],
  "payments": [...],
  "audit_trails": [...],
  "last_sync_at": "2026-01-09T09:00:00Z"
}
```

#### Sync Upload Response
```json
{
  "code": 0,
  "message": "Data synced successfully",
  "data": {
    "sync_id": "sync_123",
    "processed_users": 1,
    "processed_products": 1,
    "processed_categories": 1,
    "processed_orders": 1,
    "processed_payments": 1,
    "processed_audits": 1,
    "failed_users": 0,
    "failed_products": 0,
    "failed_categories": 0,
    "failed_orders": 0,
    "failed_payments": 0,
    "failed_audits": 0,
    "conflicts": [],
    "user_mapping": {
      "user_local_uuid_1": 25
    },
    "product_mapping": {
      "product_local_uuid_1": 150
    },
    "category_mapping": {
      "category_local_uuid_1": 15
    },
    "order_mapping": {
      "order_local_uuid_1": 456
    },
    "payment_mapping": {
      "payment_local_uuid_1": 789
    },
    "audit_mapping": {
      "audit_local_uuid_1": 1001
    },
    "sync_timestamp": "2026-01-09T10:30:15Z",
    "errors": []
  }
}
```

#### Sync Download Request
```json
{
  "client_id": "device_uuid_12345",
  "last_sync_at": "2026-01-09T09:00:00Z",
  "entity_types": ["tenants", "branches", "users", "products", "categories"]
}
```

#### Sync Download Response
```json
{
  "code": 0,
  "message": "Data downloaded successfully",
  "data": {
    "tenants": [...],
    "branches": [...],
    "users": [...],
    "products": [...],
    "categories": [...],
    "sync_timestamp": "2026-01-09T10:30:15Z",
    "has_more": false
  }
}
```

## 🔧 File yang Perlu Dibuat/Diupdate

### 1. Sync Service
**File:** `lib/shared/services/sync_service.dart`
- Implementasi upload data ke server
- Implementasi download data dari server
- Mapping local ID ke server ID
- Conflict resolution

### 2. PIN Management
**File:** `lib/pin/services/pin_service.dart`
- Create PIN
- Change PIN
- Check PIN status
- Admin change PIN

### 3. Audit Trail Service
**File:** `lib/audit-trails/services/audit_trail_service.dart`
- List audit trails
- Get audit trail by ID
- Get entity history
- Get user activity

### 4. Health Check Enhanced
**File:** `lib/shared/services/health_check_service.dart`
- Update untuk support struktur response baru
- Tambah monitoring system resources
- Database connection pool info

### 5. Models untuk Sync
**Files:**
- `lib/shared/models/sync_upload_request.dart`
- `lib/shared/models/sync_upload_response.dart`
- `lib/shared/models/sync_download_request.dart`
- `lib/shared/models/sync_download_response.dart`

### 6. Models untuk PIN
**Files:**
- `lib/pin/models/pin_model.dart`
- `lib/pin/models/pin_request.dart`

### 7. Models untuk Audit
**Files:**
- `lib/audit-trails/models/audit_trail_model.dart`

## 📝 Prioritas Implementasi

### Priority 1 (High) - Sync Integration
1. ✅ Create sync models
2. ✅ Implement sync service
3. ✅ Integrate with offline service
4. ✅ Test upload/download flow

### Priority 2 (Medium) - PIN Management
1. ⏳ Create PIN models
2. ⏳ Implement PIN service
3. ⏳ Create PIN UI
4. ⏳ Test PIN flow

### Priority 3 (Medium) - Audit Trails
1. ⏳ Create audit models
2. ⏳ Implement audit service
3. ⏳ Create audit UI
4. ⏳ Test audit flow

### Priority 4 (Low) - Health Check Enhancement
1. ⏳ Update health check model
2. ⏳ Update health check service
3. ⏳ Add system monitoring UI

## 🎯 Next Steps

1. **Buat Models untuk Sync** - Define struktur data request/response
2. **Implement Sync Service** - Connect offline service dengan API
3. **Test Sync Flow** - Pastikan upload/download berjalan baik
4. **Implement PIN Management** - Add security layer
5. **Implement Audit Trails** - Add tracking & monitoring
6. **Update Documentation** - Document all API changes

---

**Status:** 🚧 In Progress
**Last Updated:** 2026-01-09

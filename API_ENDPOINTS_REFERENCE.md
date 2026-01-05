# API Endpoints Reference

Dokumentasi ini berdasarkan Postman Collection: `MyPOSCore.postman_collection.json`

## Base Configuration

```dart
Base URL: http://localhost:8080
API Version: v1
API Prefix: /api/v1
```

## Public Endpoints (No Auth Required)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Health check - server status, database connection, uptime |
| `/dev/tenants` | GET | List all tenants (development/testing only) |
| `/dev/tenants/:id/branches` | GET | List branches for specific tenant (development only) |
| `/api/v1/faq` | GET | List FAQ (public access) |
| `/api/v1/faq/:id` | GET | Get specific FAQ (public access) |
| `/api/v1/tnc` | GET | List Terms & Conditions (public access) |
| `/api/v1/tnc/:id` | GET | Get specific T&C (public access) |

## Authentication Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/auth/register` | POST | Register new user |
| `/api/v1/auth/login` | POST | Login with username/password |

## User Endpoints (Requires Auth)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/profile` | GET | Get user profile |
| `/api/v1/profile` | PUT | Update user profile |
| `/api/v1/change-password` | POST | Change user password |

## Tenant Management (Superadmin/Authenticated Users)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/tenants` | GET | List all tenants (with pagination) |
| `/api/v1/tenants/:id` | GET | Get specific tenant |
| `/api/v1/tenants` | POST | Create new tenant (superadmin) |
| `/api/v1/tenants/:id` | PUT | Update tenant (superadmin) |
| `/api/v1/tenants/:id` | DELETE | Delete tenant (superadmin) |

**Note**: For superadmin endpoints, use the same `/api/v1/tenants` path. Access control is handled via JWT role.

## Branch Management

| Endpoint | Method | Description | Query Params |
|----------|--------|-------------|--------------|
| `/api/v1/branches` | GET | List branches (filtered by tenant from JWT) | `tenant_id` (for superadmin), `page`, `page_size` |
| `/api/v1/branches/:id` | GET | Get specific branch | - |
| `/api/v1/branches` | POST | Create new branch | - |
| `/api/v1/branches/:id` | PUT | Update branch | - |
| `/api/v1/branches/:id` | DELETE | Delete branch | - |
| `/api/v1/branches/:id/users` | GET | Get users in branch | - |

**Important**: 
- Regular users: branches are automatically filtered by their tenant_id from JWT token
- Superadmin: can pass `tenant_id` query parameter to view branches of specific tenant

## Product Management

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/products` | GET | List products |
| `/api/v1/products/:id` | GET | Get specific product |
| `/api/v1/products` | POST | Create product |
| `/api/v1/products/:id` | PUT | Update product |
| `/api/v1/products/:id` | DELETE | Delete product |

## Order Management

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/orders` | GET | List orders |
| `/api/v1/orders/:id` | GET | Get specific order |
| `/api/v1/orders` | POST | Create order |
| `/api/v1/orders/:id` | PUT | Update order |
| `/api/v1/orders/:id` | DELETE | Delete order |

## Payment Management

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/payments` | GET | List payments |
| `/api/v1/payments/:id` | GET | Get specific payment |
| `/api/v1/payments` | POST | Create payment |
| `/api/v1/payments/:id` | PUT | Update payment |
| `/api/v1/payments/:id` | DELETE | Delete payment |

## PIN Management

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/pin/create` | POST | Create PIN for user |
| `/api/v1/pin/change` | POST | Change user PIN |
| `/api/v1/pin/check` | POST | Verify PIN |

## Dashboard

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/dashboard` | GET | Get dashboard statistics (tenants, branches, users, products, transactions) |
| `/api/v1/superadmin/dashboard` | GET | Get superadmin dashboard |

## Superadmin - FAQ Management

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/superadmin/faq` | GET | List all FAQs (admin) |
| `/api/v1/superadmin/faq/:id` | GET | Get specific FAQ (admin) |
| `/api/v1/superadmin/faq` | POST | Create FAQ |
| `/api/v1/superadmin/faq/:id` | PUT | Update FAQ |
| `/api/v1/superadmin/faq/:id` | DELETE | Delete FAQ |

## Superadmin - Terms & Conditions Management

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/superadmin/tnc` | GET | List all T&C (admin) |
| `/api/v1/superadmin/tnc/:id` | GET | Get specific T&C (admin) |
| `/api/v1/superadmin/tnc` | POST | Create T&C |
| `/api/v1/superadmin/tnc/:id` | PUT | Update T&C |
| `/api/v1/superadmin/tnc/:id` | DELETE | Delete T&C |

## Superadmin - User Management

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/superadmin/branches/:branch_id/users` | GET | Get users in specific branch |

## Role-Based Access Control

**Roles:**
- `superadmin` - Full system access, manage all tenants, FAQ & TnC
- `tenantadmin` - Manage tenant-level resources
- `branchadmin` - Manage branch-level resources  
- `user` / `staff` - Regular user access

**Authentication:**
- JWT token with 24h expiry
- Token contains: user_id, tenant_id, branch_id, role
- Header: `Authorization: Bearer <token>`

## API Response Format

### Success Response
```json
{
  "code": 0,
  "message": "Operation successful",
  "data": { ... }
}
```

### Paginated Response
```json
{
  "code": 0,
  "message": "Operation successful",
  "data": {
    "page": 1,
    "page_size": 20,
    "total_items": 100,
    "total_pages": 5,
    "data": [ ... ]
  }
}
```

### Error Response
```json
{
  "code": 1,
  "message": "Error message",
  "data": null
}
```

## Common Query Parameters

- `page` - Page number (default: 1)
- `page_size` - Items per page (default: 20, max: 100)
- `tenant_id` - Filter by tenant (superadmin only)
- `branch_id` - Filter by branch

## Fixed Issues

### 1. Missing API Endpoints in ApiConfig
**Problem**: Services were using undefined API endpoints
- `ApiConfig.superadminTenants` - undefined
- `ApiConfig.superadminTenantBranches(tenantId)` - undefined

**Solution**: Added missing endpoints to [api_config.dart](lib/shared/config/api_config.dart):
```dart
// Superadmin Tenant endpoints
static const String superadminTenants = '$apiPrefix/tenants';

// Superadmin tenant branches endpoint
static String superadminTenantBranches(int tenantId) =>
    '$apiPrefix/branches?tenant_id=$tenantId';
```

### 2. Query Parameter Concatenation
**Problem**: URL query parameters were being added incorrectly in [branches_management_service.dart](lib/branches/services/branches_management_service.dart)

**Before**:
```dart
String url = ApiConfig.superadminTenantBranches(tenantId);
url += '?page=$page&page_size=$pageSize'; // Wrong: creates ??page=...
```

**After**:
```dart
String url = ApiConfig.superadminTenantBranches(tenantId);
url += '&page=$page&page_size=$pageSize'; // Correct: creates &page=...
```

### 3. Files Fixed
- [lib/shared/config/api_config.dart](lib/shared/config/api_config.dart) - Added missing endpoint definitions
- [lib/branches/services/branches_management_service.dart](lib/branches/services/branches_management_service.dart) - Fixed query parameter concatenation
- [lib/tenants/services/tenants_management_service.dart](lib/tenants/services/tenants_management_service.dart) - Now uses correct endpoint
- [lib/common/superadmin_tenants_service.dart](lib/common/superadmin_tenants_service.dart) - Now uses correct endpoint
- [lib/common/superadmin_branches_service.dart](lib/common/superadmin_branches_service.dart) - Now uses correct endpoint

## Verification

✅ All compilation errors resolved
✅ Flutter analyze completed with no errors (only info warnings)
✅ API endpoints aligned with Postman collection
✅ Query parameters properly formatted

---
Last updated: January 5, 2026

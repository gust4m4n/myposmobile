# Login Simplification Update

## Overview
Updated login functionality to match the new API specification where users only need to provide username and password. The backend now automatically handles tenant and branch assignment based on the user account.

## Changes Made

### 1. API Service (`lib/login/login_service.dart`)
- **Removed parameters**: `tenantCode` and `branchCode`
- **Kept parameters**: `username` and `password`
- **Endpoint**: `POST /api/v1/auth/login`
- **Request body**: 
  ```json
  {
    "username": "string",
    "password": "string"
  }
  ```
- **Response includes**:
  - `token`: JWT authentication token (24h expiry)
  - `user`: Complete user object with `tenant_id`, `branch_id`, `role`, etc.
  - `tenant`: Complete tenant object with `name`, `code`, `description`
  - `branch`: Complete branch object with `name`, `code`, `address`

### 2. Login Page UI (`lib/login/login_page.dart`)
- **Removed UI elements**:
  - Tenant dropdown field (`_buildTenantDropdown`)
  - Branch dropdown field (`_buildBranchDropdown`)
- **Kept UI elements**:
  - Username text field
  - Password text field
  - Login button
  - Language selector
  - Terms & Conditions / FAQ links

### 3. Login Controller (`lib/login/login_controller.dart`)
- **Removed properties**:
  - `isLoadingTenants`
  - `isLoadingBranches`
  - `tenants` list
  - `branches` list
  - `selectedTenant`
  - `selectedBranch`
- **Removed methods**:
  - `loadTenants()`
  - `loadBranches(int tenantId)`
- **Removed validation checks**:
  - Tenant selection validation
  - Branch selection validation
- **Updated login method**:
  - Calls `loginService.login()` with only `username` and `password`
  - Backend automatically determines tenant and branch from user account

### 4. Removed Dependencies
- No longer imports:
  - `dev_branches_service.dart`
  - `dev_tenants_service.dart`

## Benefits
1. **Simplified UX**: Users only need username and password to login
2. **Reduced API calls**: No need to fetch tenants and branches before login
3. **Better security**: Tenant/branch assignment managed by backend
4. **Cleaner code**: Removed 2 dropdowns, 2 API calls, 6 reactive variables

## Migration Notes
- Usernames must be unique across the entire system (not just per tenant)
- Backend automatically assigns users to their configured tenant and branch
- Login response now includes full user, tenant, and branch details
- No changes needed to other parts of the application as the auth flow remains the same after login

## Testing
To test the updated login:
1. Use any existing user credentials (e.g., `branchadmin` / `123456`)
2. No need to select tenant or branch
3. System automatically logs in to the correct tenant/branch
4. Profile and navigation work as before

## Debug Mode
Debug mode still pre-fills credentials for faster testing:
- Username: `branchadmin`
- Password: `123456`

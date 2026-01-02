# Translation Keys Analysis Report

**Generated:** January 2, 2026  
**Project:** MyPOSMobile Flutter Application

---

## Executive Summary

This report provides a comprehensive analysis of all translation keys used throughout the MyPOSMobile application and compares them against the defined translations in `en.dart` and `id.dart` files.

### Quick Stats

- **Total Translation Keys Used in Code:** 202
- **Total Keys Defined in en.dart:** 231
- **Total Keys Defined in id.dart:** 231
- **Missing Keys in en.dart:** 14
- **Missing Keys in id.dart:** 14
- **Unused Keys (Defined but Never Used):** 43

---

## 1. Translation Keys Used in Code

Total unique translation keys found in codebase: **202**

### All Keys Used in Code:
```
action, actions, active, activeStatus, addBranch, addProduct, address, 
addTenant, addUser, all, amount, applyFilters, appTitle, auditTrail, 
auditTrails, basicInformation, branch, branchCreatedSuccess, 
branchCreationFailed, branchDeleteFailed, branchesManagement, branchId, 
branchIdInvalid, branchIdRequired, branchName, branchRequired, 
branchUpdateFailed, cancel, card, cart, cash, category, categoryRequired, 
change, changeImage, changePassword, changePin, changes, changing, 
checkout, checkoutTitle, clearFilters, close, confirmDeleteUser, 
confirmNewPassword, confirmPin, created, createdAt, createPin, 
currentPassword, currentPin, dateFrom, dateLabel, dateTo, delete, 
deleteBranch, deleteBranchConfirmation, deletePhoto, 
deletePhotoConfirmation, deleteProduct, deleteProductConfirmation, 
deleteTenant, deleteTenantConfirmation, deleteUser, deleting, 
description, descriptionRequired, edit, editBranch, editProduct, 
editProfile, editTenant, editUser, email, emailInvalid, emailRequired, 
emptyCart, english, entity, entityId, entityType, faq, fieldRequired, 
fileSizeExceeded, filters, fullName, fullNameRequired, image, inactive, 
indonesian, invalidEmail, isActive, language, leaveEmptyToKeepCurrent, 
loggingIn, login, loginButton, logout, logoutConfirmation, menu, method, 
name, newPassword, newPin, noAuditTrails, noBranchesFound, noChanges, 
noOrders, noPayments, noProfileData, noTenantsFound, notes, notSet, 
noUsers, optional, orderDetails, orderDetailsLabel, orderFailed, orderId, 
orderItems, orderNumber, orderNumberLabel, orders, password, 
passwordChangedSuccessfully, passwordMinLength, passwordMustBe6Characters, 
passwordRequired, passwordsDoNotMatch, paymentFailed, paymentId, payments, 
phone, photoDeletedSuccess, photoDeleteFailed, photoPickFailed, 
photoTooLarge, photoUploadedSuccess, photoUploadFailed, pin, 
pinChangedSuccess, pinChangeFailed, pinCreatedSuccess, pinCreateFailed, 
pinsDoNotMatch, pleaseConfirmPassword, pleaseConfirmPin, 
pleaseEnterCurrentPassword, pleaseEnterCurrentPin, pleaseEnterEmail, 
pleaseEnterNewPassword, pleaseEnterPassword, pleaseEnterPin, 
pleaseEnterValidEmail, price, priceInvalid, priceRequired, printReceipt, 
product, productCreatedFailed, productCreatedSuccess, 
productDeletedFailed, productDeletedSuccess, productName, 
productNameRequired, productPhoto, productsManagement, 
productUpdatedFailed, productUpdatedSuccess, profile, profilePhoto, 
profileUpdatedSuccess, profileUpdateFailed, qty, receiptFailed, 
receiptSaved, receiptTitle, role, save, saving, selectImage, 
selectLanguage, selectPhoto, selectTenant, sku, skuRequired, status, 
stock, stockInvalid, stockRequired, subtotal, tenantCreatedSuccess, 
tenantCreationFailed, tenantDeletedSuccess, tenantDeleteFailed, tenantId, 
tenantIdNotFound, tenantName, tenantsManagement, tenantUpdatedSuccess, 
tenantUpdateFailed, termsAndConditions, thankYou, timestamp, total, 
totalAmount, totalPayment, totalUsers, transactionSuccess, uploading, 
uploadPhoto, user, userCreatedFailed, userCreatedSuccess, 
userDeletedSuccess, userDeleteFailed, userId, userManagement, 
userUpdatedFailed, userUpdatedSuccess, viewActive, viewAll, website
```

---

## 2. Missing Translation Keys in en.dart

The following **14 keys** are used in the code but are **NOT defined** in `en.dart`:

| # | Key Name | Priority | Suggested Translation (en) |
|---|----------|----------|---------------------------|
| 1 | `branch` | High | Branch |
| 2 | `branchRequired` | High | Branch is required |
| 3 | `change` | Medium | Change |
| 4 | `failedToLoadBranches` | High | Failed to load branches |
| 5 | `failedToPickImage` | Medium | Failed to pick image |
| 6 | `image` | High | Image |
| 7 | `orderFailed` | High | Order failed |
| 8 | `paymentFailed` | High | Payment failed |
| 9 | `pinMustBe6Digits` | High | PIN must be 6 digits |
| 10 | `selectTenantFirst` | Medium | Please select a tenant first |
| 11 | `tenantCreationFailed` | High | Failed to create tenant |
| 12 | `tenantId` | Medium | Tenant ID |
| 13 | `tenantIdNotFound` | High | Tenant ID not found |
| 14 | `tenantUpdateFailed` | High | Failed to update tenant |

---

## 3. Missing Translation Keys in id.dart

The following **14 keys** are used in the code but are **NOT defined** in `id.dart`:

| # | Key Name | Priority | Suggested Translation (id) |
|---|----------|----------|---------------------------|
| 1 | `branch` | High | Cabang |
| 2 | `branchRequired` | High | Cabang wajib dipilih |
| 3 | `change` | Medium | Ubah |
| 4 | `failedToLoadBranches` | High | Gagal memuat cabang |
| 5 | `failedToPickImage` | Medium | Gagal memilih gambar |
| 6 | `image` | High | Gambar |
| 7 | `orderFailed` | High | Pesanan gagal |
| 8 | `paymentFailed` | High | Pembayaran gagal |
| 9 | `pinMustBe6Digits` | High | PIN harus 6 digit |
| 10 | `selectTenantFirst` | Medium | Silakan pilih tenant terlebih dahulu |
| 11 | `tenantCreationFailed` | High | Gagal membuat tenant |
| 12 | `tenantId` | Medium | ID Tenant |
| 13 | `tenantIdNotFound` | High | ID Tenant tidak ditemukan |
| 14 | `tenantUpdateFailed` | High | Gagal memperbarui tenant |

---

## 4. Unused Translation Keys

The following **43 keys** are defined in translation files but are **NEVER used** in the code:

### Category: Products (8 keys)
- `friedRice` - Fried Rice / Nasi Goreng
- `friedNoodles` - Fried Noodles / Mie Goreng
- `friedChicken` - Fried Chicken / Ayam Goreng
- `chickenSatay` - Chicken Satay / Sate Ayam
- `icedTea` - Iced Tea / Es Teh
- `orangeJuice` - Orange Juice / Es Jeruk
- `coffee` - Coffee / Kopi
- `avocadoJuice` - Avocado Juice / Jus Alpukat

### Category: UI Elements (10 keys)
- `all` - All / Semua
- `food` - Food / Makanan
- `drinks` - Drinks / Minuman
- `retry` - Retry / Coba Lagi
- `lightMode` - Light Mode / Mode Terang
- `darkMode` - Dark Mode / Mode Gelap
- `done` - Done / Selesai
- `unknown` - Unknown / Tidak Diketahui
- `notAvailable` - N/A / T/A
- `pay` - Pay / Bayar

### Category: Login/Auth (10 keys)
- `tenantCode` - Tenant Code / Kode Tenant
- `branchCode` - Branch Code / Kode Cabang
- `username` - Username / Username
- `loginSuccess` - Login successful! / Login berhasil!
- `loginFailed` - Login failed / Login gagal
- `pleaseEnterTenantCode` - Please enter tenant code / Mohon masukkan kode tenant
- `pleaseEnterBranchCode` - Please enter branch code / Mohon masukkan kode cabang
- `pleaseEnterUsername` - Please enter username / Mohon masukkan username
- `loadingTenants` - Loading tenants... / Memuat tenant...
- `loadingBranches` - Loading branches... / Memuat cabang...

### Category: PIN Management (2 keys)
- `createPinInstructions` - Create a 6-digit PIN for quick authentication
- `changePinInstructions` - Enter your current PIN and a new 6-digit PIN

### Category: Profile (2 keys)
- `selectPhoto` - Select Photo / Pilih Foto
- `deletePhoto` - Delete Photo / Hapus Foto

### Category: Pages (5 keys)
- `changeYourPassword` - Change Your Password / Ubah Password Anda
- `changePasswordInstructions` - Enter your current password and a new password
- `searchFaqs` - Search FAQs... / Cari FAQ...
- `faqsFound` - {count} FAQ(s) found / {count} FAQ ditemukan
- `noFaqsFound` - No FAQs found / Tidak ada FAQ ditemukan

### Category: Receipt/PDF (2 keys)
- `openFolder` - Open Folder / Buka Folder
- `totalRecords` - Total Records: {count} / Total Record: {count}

### Category: Other (4 keys)
- `selectBranch` - Select Branch / Pilih Cabang
- `page` - Page / Halaman
- `refresh` - Refresh / Refresh
- `technicalInformation` - Technical Information / Informasi Teknis
- `ipAddress` - IP Address / Alamat IP
- `userAgent` - User Agent / User Agent
- `rawJsonData` - Raw JSON Data / Data JSON Mentah
- `details` - Details / Detail
- `viewDetails` - View Details / Lihat Detail
- `noMoreData` - No more data / Tidak ada data lagi
- `usernameRequired` - Username is required / Username wajib diisi
- `usernameMinLength` - Username must be at least 3 characters / Username minimal 3 karakter
- `loadTenantsFailed` - Failed to load tenants / Gagal memuat tenant
- `loadBranchesFailed` - Failed to load branches / Gagal memuat cabang

---

## 5. Recommendations

### Critical Priority (Must Fix)
1. **Add missing high-priority keys** to both `en.dart` and `id.dart`:
   - `branch`, `branchRequired`, `image`
   - `orderFailed`, `paymentFailed`
   - `failedToLoadBranches`
   - `tenantCreationFailed`, `tenantUpdateFailed`, `tenantIdNotFound`

### Medium Priority (Should Fix)
2. **Add missing medium-priority keys**:
   - `change`, `failedToPickImage`, `tenantId`
   - `selectTenantFirst`, `pinMustBe6Digits`

### Low Priority (Cleanup)
3. **Review and handle unused keys**:
   - Consider removing unused product names if they're hardcoded data
   - Keep UI element keys if they might be used in future features
   - Remove truly obsolete keys to reduce translation file size

### Best Practices
4. **Establish key naming conventions**:
   - Use consistent patterns: `[action][Entity][Status]`
   - Example: `branchCreatedSuccess`, `branchCreationFailed`

5. **Add validation**:
   - Consider adding automated tests to catch missing translations
   - Use a CI/CD check to verify translation completeness

---

## 6. Files to Update

### Add to en.dart:
```dart
// Missing Keys - Add these to en.dart
'branch': 'Branch',
'branchRequired': 'Branch is required',
'change': 'Change',
'failedToLoadBranches': 'Failed to load branches',
'failedToPickImage': 'Failed to pick image',
'image': 'Image',
'orderFailed': 'Order failed',
'paymentFailed': 'Payment failed',
'pinMustBe6Digits': 'PIN must be 6 digits',
'selectTenantFirst': 'Please select a tenant first',
'tenantCreationFailed': 'Failed to create tenant',
'tenantId': 'Tenant ID',
'tenantIdNotFound': 'Tenant ID not found',
'tenantUpdateFailed': 'Failed to update tenant',
```

### Add to id.dart:
```dart
// Missing Keys - Add these to id.dart
'branch': 'Cabang',
'branchRequired': 'Cabang wajib dipilih',
'change': 'Ubah',
'failedToLoadBranches': 'Gagal memuat cabang',
'failedToPickImage': 'Gagal memilih gambar',
'image': 'Gambar',
'orderFailed': 'Pesanan gagal',
'paymentFailed': 'Pembayaran gagal',
'pinMustBe6Digits': 'PIN harus 6 digit',
'selectTenantFirst': 'Silakan pilih tenant terlebih dahulu',
'tenantCreationFailed': 'Gagal membuat tenant',
'tenantId': 'ID Tenant',
'tenantIdNotFound': 'ID Tenant tidak ditemukan',
'tenantUpdateFailed': 'Gagal memperbarui tenant',
```

---

## 7. Impact Analysis

### Current Impact
- **14 missing translations** will currently show the key name instead of proper text
- This affects user experience in both English and Indonesian languages
- High-priority keys affect critical user flows (orders, payments, branches)

### Risk Level: **HIGH**
Missing translations in error messages and critical features may confuse users and reduce app usability.

---

## 8. Next Steps

1. ✅ Review this report
2. ⬜ Add all 14 missing keys to both `en.dart` and `id.dart`
3. ⬜ Test the application in both languages
4. ⬜ Review unused keys and decide which to keep/remove
5. ⬜ Implement automated translation validation in CI/CD
6. ⬜ Document translation key naming conventions

---

**Report End**

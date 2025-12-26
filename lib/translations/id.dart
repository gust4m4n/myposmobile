const Map<String, String> id = {
  // App
  'appTitle': 'MyPOSMobile',

  // Categories
  'all': 'Semua',
  'food': 'Makanan',
  'drinks': 'Minuman',

  // Products
  'friedRice': 'Nasi Goreng',
  'friedNoodles': 'Mie Goreng',
  'friedChicken': 'Ayam Goreng',
  'chickenSatay': 'Sate Ayam',
  'icedTea': 'Es Teh',
  'orangeJuice': 'Es Jeruk',
  'coffee': 'Kopi',
  'avocadoJuice': 'Jus Alpukat',

  // Cart
  'cart': 'Keranjang Belanja',
  'emptyCart': 'Keranjang Kosong',
  'total': 'Total:',
  'checkout': 'Checkout',
  'retry': 'Coba Lagi',

  // Checkout Dialog
  'checkoutTitle': 'Checkout',
  'totalPayment': 'Total pembayaran: {amount}',
  'cancel': 'Batal',
  'pay': 'Bayar',
  'transactionSuccess': 'Transaksi berhasil!',

  // Theme
  'lightMode': 'Mode Terang',
  'darkMode': 'Mode Gelap',

  // Language
  'language': 'Bahasa',
  'english': 'English',
  'indonesian': 'Indonesia',

  // Sidebar
  'profile': 'Profil',
  'orders': 'Pesanan',
  'payments': 'Pembayaran',
  'logout': 'Keluar',
  'logoutConfirmation': 'Apakah Anda yakin ingin keluar?',

  // Orders
  'noOrders': 'Belum ada pesanan',
  'orderDetails': 'Detail Pesanan',
  'orderItems': 'Item Pesanan',
  'orderId': 'ID Pesanan',
  'close': 'Tutup',
  'price': 'Harga',

  // Payments
  'noPayments': 'Belum ada pembayaran',
  'method': 'Metode',

  // Login
  'login': 'Masuk',
  'tenantCode': 'Kode Tenant',
  'branchCode': 'Kode Cabang',
  'username': 'Username',
  'password': 'Password',
  'loginButton': 'Masuk',
  'loggingIn': 'Sedang masuk...',
  'loginSuccess': 'Login berhasil!',
  'loginFailed': 'Login gagal',
  'pleaseEnterTenantCode': 'Mohon masukkan kode tenant',
  'pleaseEnterBranchCode': 'Mohon masukkan kode cabang',
  'pleaseEnterUsername': 'Mohon masukkan username',
  'pleaseEnterPassword': 'Mohon masukkan password',

  // Change Password
  'changePassword': 'Ubah Password',
  'currentPassword': 'Password Saat Ini',
  'newPassword': 'Password Baru',
  'confirmNewPassword': 'Konfirmasi Password Baru',
  'pleaseEnterCurrentPassword': 'Mohon masukkan password saat ini',
  'pleaseEnterNewPassword': 'Mohon masukkan password baru',
  'pleaseConfirmPassword': 'Mohon konfirmasi password baru',
  'passwordsDoNotMatch': 'Password tidak cocok',
  'passwordMustBe6Characters': 'Password minimal 6 karakter',
  'passwordChangedSuccessfully': 'Password berhasil diubah',
  'changing': 'Mengubah...',

  // Login Page Additional
  'loadingTenants': 'Memuat tenant...',
  'loadingBranches': 'Memuat cabang...',
  'selectTenant': 'Pilih Tenant',
  'selectBranch': 'Pilih Cabang',
  'selectTenantFirst': 'Pilih tenant terlebih dahulu',

  // Profile Page
  'noProfileData': 'Tidak ada data profil',

  // Orders Page Additional
  'orderNumber': 'Nomor Pesanan',
  'totalAmount': 'Total Jumlah',
  'status': 'Status',
  'createdAt': 'Dibuat Pada',

  // Payments Page Additional
  'paymentId': 'ID Pembayaran',
  'amount': 'Jumlah',

  // Table Columns
  'product': 'Produk',
  'qty': 'Qty',
  'subtotal': 'Subtotal',

  // Common Labels
  'notes': 'Catatan',
  'created': 'Dibuat',

  // FAQ & TNC
  'faq': 'FAQ',
  'termsAndConditions': 'Syarat & Ketentuan',
  'viewAll': 'Lihat Semua',
  'viewActive': 'Lihat Aktif',
  'active': 'Aktif',

  // Payment Methods
  'cash': 'Tunai',
  'card': 'Kartu',
  'transfer': 'Transfer',
  'qris': 'QRIS',

  // Receipt/PDF
  'receiptTitle': 'STRUK PEMBAYARAN',
  'orderNumberLabel': 'No. Order',
  'dateLabel': 'Tanggal',
  'orderDetailsLabel': 'DETAIL PESANAN',
  'thankYou': 'Terima Kasih',
  'receiptSaved': 'Struk berhasil disimpan: {fileName}',
  'openFolder': 'Buka Folder',
  'receiptFailed': 'Gagal membuat struk: {error}',
  'printReceipt': 'Cetak Struk',
  'done': 'Selesai',

  // Common
  'menu': 'Menu',
  'user': 'Pengguna',
  'notAvailable': 'T/A',
  'unknown': 'Tidak Diketahui',
  'selectLanguage': 'Pilih Bahasa',

  // Change Password Page
  'changeYourPassword': 'Ubah Password Anda',
  'changePasswordInstructions': 'Masukkan password saat ini dan password baru',

  // FAQ Page
  'searchFaqs': 'Cari FAQ...',
  'faqsFound': '{count} FAQ ditemukan',
  'noFaqsFound': 'Tidak ada FAQ ditemukan',

  // Products Management
  'productsManagement': 'Manajemen Produk',
  'addProduct': 'Tambah Produk',
  'productName': 'Nama Produk',
  'description': 'Deskripsi',
  'category': 'Kategori',
  'sku': 'SKU',
  'stock': 'Stok',
  'isActive': 'Aktif',
  'productNameRequired': 'Nama produk wajib diisi',
  'descriptionRequired': 'Deskripsi wajib diisi',
  'categoryRequired': 'Kategori wajib diisi',
  'skuRequired': 'SKU wajib diisi',
  'priceRequired': 'Harga wajib diisi',
  'priceInvalid': 'Harga harus lebih dari 0',
  'stockRequired': 'Stok wajib diisi',
  'stockInvalid': 'Stok harus 0 atau lebih',
  'save': 'Simpan',
  'saving': 'Menyimpan...',
  'productCreatedSuccess': 'Produk berhasil dibuat',
  'productCreatedFailed': 'Gagal membuat produk',
};

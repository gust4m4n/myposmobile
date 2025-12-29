# Migrasi GetX - MyPOSMobile

## Status Implementasi

### ✅ Selesai

1. **Dependency GetX**
   - Ditambahkan `get: ^4.6.6` ke pubspec.yaml
   - Berhasil diinstall: `flutter pub get` ✓

2. **Controllers Utama**
   - `AuthController` - Mengelola autentikasi dan token
   - `LanguageController` - Mengelola preferensi bahasa
   - `ProfileController` - Mengelola data profil pengguna
   - `LoginController` - State management untuk halaman login
   - `HomeController` - State management untuk halaman home (ready to use)

3. **Main.dart**
   - ✓ Diupdate menggunakan `GetMaterialApp`
   - ✓ Inisialisasi controllers dengan `Get.put()`
   - ✓ Navigation key menggunakan `Get.key`
   - ✓ Reactive state dengan `Obx()`
   - ✓ Auto-routing berdasarkan authentication state

4. **LoginPage**
   - ✓ Diubah dari `StatefulWidget` ke `StatelessWidget`
   - ✓ Menggunakan `LoginController` untuk state management
   - ✓ Navigation dengan `Get.to()` dan `Get.back()`
   - ✓ Reactive UI dengan `Obx()`
   - ✓ Form validation menggunakan GetX

5. **HomePage**
   - ✓ Import GetX dan controllers ditambahkan
   - ✓ Logout menggunakan `AuthController`
   - ✓ Language toggle menggunakan `LanguageController`
   - ℹ️ Masih menggunakan StatefulWidget (bisa di-refactor nanti)

### ⚠️ Catatan Penting

**Konflik Extension `.tr`**
- GetX memiliki extension `.tr` untuk internationalization
- Aplikasi ini sudah menggunakan `TranslationExtension` custom dengan nama `.tr`
- **Solusi**: Tetap gunakan `TranslationExtension` yang sudah ada
- GetX `.tr` tidak digunakan untuk menghindari konflik
- Untuk translation, tetap gunakan cara yang sudah ada:
  ```dart
  TranslationService.setLanguage(languageCode);
  Text('login'.tr)  // Menggunakan TranslationExtension (bukan GetX .tr)
  ```

## Cara Menggunakan GetX di Aplikasi Ini

### Navigation

**Sebelum (Navigator):**
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => NextPage()),
);
```

**Sesudah (GetX):**
```dart
Get.to(() => NextPage());
```

**Navigasi dengan data:**
```dart
Get.to(() => NextPage(), arguments: {'id': 123});

// Di NextPage
final args = Get.arguments as Map<String, dynamic>;
final id = args['id'];
```

**Navigasi back:**
```dart
Get.back();
Get.back(result: someData); // dengan return value
```

**Replace (mengganti halaman):**
```dart
Get.off(() => NextPage()); // Replace current
Get.offAll(() => HomePage()); // Clear semua stack
```

### State Management

**Buat Controller:**
```dart
class MyController extends GetxController {
  // Observable state
  final count = 0.obs;
  final name = ''.obs;
  final isLoading = false.obs;
  
  // Computed property
  String get displayName => 'Hello, ${name.value}';
  
  // Methods
  void increment() => count.value++;
  
  void updateName(String newName) {
    name.value = newName;
  }
  
  @override
  void onInit() {
    super.onInit();
    // Initialization code
  }
  
  @override
  void onClose() {
    // Cleanup code
    super.onClose();
  }
}
```

**Gunakan di Widget:**
```dart
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyController());
    
    return Obx(() => Text('Count: ${controller.count.value}'));
  }
}
```

### Dependency Injection

**Register controller:**
```dart
// Langsung register saat digunakan
final controller = Get.put(MyController());

// Lazy loading (hanya dibuat saat digunakan)
Get.lazyPut(() => MyController());

// Singleton
Get.put(MyController(), permanent: true);
```

**Akses controller dari mana saja:**
```dart
final controller = Get.find<MyController>();
```

### Reactive Lists

```dart
class ProductsController extends GetxController {
  final products = <Product>[].obs;
  
  void addProduct(Product product) {
    products.add(product);
  }
  
  void removeProduct(int index) {
    products.removeAt(index);
  }
  
  void updateProduct(int index, Product product) {
    products[index] = product;
    products.refresh(); // Notify observers
  }
}

// Di widget
Obx(() => ListView.builder(
  itemCount: controller.products.length,
  itemBuilder: (context, index) {
    final product = controller.products[index];
    return ListTile(title: Text(product.name));
  },
))
```

### Snackbar & Dialog

**Snackbar:**
```dart
Get.snackbar(
  'Title',
  'Message',
  snackPosition: SnackPosition.TOP,
  backgroundColor: Colors.blue,
  colorText: Colors.white,
);
```

**Dialog:**
```dart
Get.dialog(
  AlertDialog(
    title: Text('Title'),
    content: Text('Content'),
    actions: [
      TextButton(
        onPressed: () => Get.back(),
        child: Text('OK'),
      ),
    ],
  ),
);
```

**Bottom Sheet:**
```dart
Get.bottomSheet(
  Container(
    child: Wrap(
      children: [
        ListTile(
          leading: Icon(Icons.music_note),
          title: Text('Music'),
          onTap: () => Get.back(),
        ),
      ],
    ),
  ),
);
```

## Contoh Migrasi HomePage

Untuk HomePage yang sudah ada, berikut langkah-langkahnya:

1. **Update class definition:**
```dart
// Sebelum
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

// Sesudah
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    // ...
  }
}
```

2. **Ganti setState dengan Reactive:**
```dart
// Sebelum
setState(() {
  _isLoading = true;
});

// Sesudah
controller.isLoading.value = true;
```

3. **Wrap widget yang perlu reactive dengan Obx:**
```dart
Obx(() => Text('Items: ${controller.cart.length}'))
```

4. **Update method untuk menggunakan controller:**
```dart
// Sebelum
void _addToCart(Product product) {
  setState(() {
    _cart.add(product);
  });
}

// Sesudah (di controller)
void addToCart(Product product) {
  cart.add(product);
}

// Di widget
onPressed: () => controller.addToCart(product)
```

## Global Controllers

Controllers yang sudah diinisialisasi di `main.dart`:
- `AuthController` - Untuk autentikasi
- `LanguageController` - Untuk bahasa
- `ProfileController` - Untuk profil pengguna

Akses dari mana saja:
```dart
final authController = Get.find<AuthController>();
final languageController = Get.find<LanguageController>();
final profileController = Get.find<ProfileController>();

// Check authentication
if (authController.isAuthenticated) {
  // User is logged in
}

// Get current language
final currentLang = languageController.languageCode.value;

// Get profile
final profile = profileController.profile.value;
```

## Testing

Jalankan aplikasi:
```bash
flutter pub get
flutter run -d macos
```

## Troubleshooting

1. **Controller not found:**
   - Pastikan controller sudah di-register dengan `Get.put()` atau `Get.lazyPut()`
   
2. **UI tidak update:**
   - Pastikan menggunakan `.obs` untuk variable yang perlu reactive
   - Wrap widget dengan `Obx(() => ...)`
   
3. **Navigation tidak bekerja:**
   - Pastikan menggunakan `GetMaterialApp` bukan `MaterialApp`
   - Gunakan `Get.to()` bukan `Navigator.push()`

## Referensi

- [GetX Documentation](https://pub.dev/packages/get)
- [GetX State Management](https://github.com/jonataslaw/getx/blob/master/documentation/en_US/state_management.md)
- [GetX Route Management](https://github.com/jonataslaw/getx/blob/master/documentation/en_US/route_management.md)

# Translation Extension Usage

Aplikasi ini menggunakan `.tr` extension untuk translation yang lebih mudah dan modern!

## Import

```dart
import '../translations/translation_extension.dart';
```

## Cara Penggunaan

### 1. Simple Translation

```dart
// Initialize language di build method
TranslationService.setLanguage(widget.languageCode);

Text('appTitle'.tr)
Text('login'.tr)
Text('logout'.tr)
```

### 2. Translation dengan Parameter

```dart
'totalPayment'.trParams({'amount': 'Rp 10.000'})
```

### 3. Usage dalam Widget

```dart
@override
Widget build(BuildContext context) {
  // Initialize translations dengan language code saat ini
  TranslationService.setLanguage(widget.languageCode);

  return Scaffold(
    appBar: AppBarX(
      title: 'payments'.tr,  // ✅ Mudah!
    ),
    body: Column(
      children: [
        Text('noPayments'.tr),
        Text('retry'.tr),
        ElevatedButton(
          onPressed: () {},
          child: Text('checkout'.tr),
        ),
      ],
    ),
  );
}
```

## Available Translation Keys

Semua key yang ada di `translations/en.dart` dan `translations/id.dart` bisa digunakan:

- `'appTitle'.tr`
- `'login'.tr`
- `'logout'.tr`
- `'profile'.tr`
- `'orders'.tr`
- `'payments'.tr`
- `'cart'.tr`
- `'checkout'.tr`
- `'total'.tr`
- `'cancel'.tr`
- `'pay'.tr`
- `'retry'.tr`
- `'noOrders'.tr`
- `'noPayments'.tr`
- dan lain-lain...

## Keuntungan

✅ **Lebih ringkas** - tidak perlu deklarasi variable localizations  
✅ **Lebih mudah dibaca** - `'title'.tr` lebih intuitif  
✅ **Konsisten** - pattern yang sama dengan package seperti GetX, easy_localization  
✅ **Type-safe** - Translation keys terpusat di en.dart dan id.dart

## Menambah Translation Baru

1. Tambahkan key ke `lib/translations/en.dart`:

   ```dart
   'newKey': 'New English Text',
   ```

2. Tambahkan key yang sama ke `lib/translations/id.dart`:

   ```dart
   'newKey': 'Teks Bahasa Indonesia Baru',
   ```

3. Gunakan langsung dengan `.tr`:

   ```dart
   Text('newKey'.tr)
   ```

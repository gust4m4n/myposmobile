# Translation Extension Usage

Sekarang Anda bisa menggunakan translation dengan cara yang lebih mudah seperti aplikasi lain!

## Import

```dart
import '../translations/translation_extension.dart';
```

## Cara Penggunaan

### 1. Simple Translation

```dart
// Sebelumnya:
final localizations = AppLocalizations.of(widget.languageCode);
Text(localizations.appTitle)

// Sekarang:
AppLocalizations.of(widget.languageCode); // Init language
Text('appTitle'.tr)
```

### 2. Translation dengan Parameter

```dart
// Sebelumnya:
localizations.totalPayment('Rp 10.000')

// Sekarang:
'totalPayment'.trParams({'amount': 'Rp 10.000'})
```

### 3. Usage dalam Widget

```dart
@override
Widget build(BuildContext context) {
  // Initialize translations dengan language code saat ini
  AppLocalizations.of(widget.languageCode);

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

✅ **Lebih ringkas** - tidak perlu `final localizations = AppLocalizations.of(...)`  
✅ **Lebih mudah dibaca** - `'title'.tr` lebih intuitif  
✅ **Konsisten** - pattern yang sama dengan package seperti GetX, easy_localization  
✅ **Backward compatible** - cara lama masih tetap bisa digunakan  

## Migration

Anda bisa migrate secara bertahap:

1. Tambahkan import `translation_extension.dart`
2. Initialize dengan `AppLocalizations.of(widget.languageCode)` di build method
3. Ganti `localizations.keyName` menjadi `'keyName'.tr`

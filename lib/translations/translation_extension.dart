import 'en.dart' as en_translations;
import 'id.dart' as id_translations;

/// Global language code storage
class TranslationService {
  static String _currentLanguageCode = 'en';

  static String get currentLanguageCode => _currentLanguageCode;

  static void setLanguage(String languageCode) {
    _currentLanguageCode = languageCode;
  }

  static Map<String, String> get _translations {
    return _currentLanguageCode == 'en'
        ? en_translations.en
        : id_translations.id;
  }

  static String translate(String key) => _translations[key] ?? key;
}

/// Extension method for easy translation
/// Usage: 'appTitle'.tr
extension TranslationExtension on String {
  String get tr => TranslationService.translate(this);

  /// Translation with parameters
  /// Usage: 'totalPayment'.trParams({'amount': '10000'})
  String trParams(Map<String, String> params) {
    String translated = TranslationService.translate(this);
    params.forEach((key, value) {
      translated = translated.replaceAll('{$key}', value);
    });
    return translated;
  }
}

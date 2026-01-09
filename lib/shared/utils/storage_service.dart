import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyAuthToken = 'auth_token';
  static const String _keyLanguageCode = 'language_code';
  static const String _keyDarkMode = 'dark_mode';
  static const String _keyWindowWidth = 'window_width';
  static const String _keyWindowHeight = 'window_height';
  static const String _keyOfflineMode = 'offline_mode';

  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // Auth Token
  Future<void> saveToken(String token) async {
    await _prefs?.setString(_keyAuthToken, token);
  }

  String? getToken() {
    return _prefs?.getString(_keyAuthToken);
  }

  Future<void> clearToken() async {
    await _prefs?.remove(_keyAuthToken);
  }

  // Language Code
  Future<void> saveLanguageCode(String languageCode) async {
    await _prefs?.setString(_keyLanguageCode, languageCode);
  }

  String getLanguageCode() {
    return _prefs?.getString(_keyLanguageCode) ?? 'en';
  }

  // Dark Mode
  Future<void> saveIsDarkMode(bool isDarkMode) async {
    await _prefs?.setBool(_keyDarkMode, isDarkMode);
  }

  bool? getIsDarkMode() {
    return _prefs?.getBool(_keyDarkMode);
  }

  // Window Size
  Future<void> saveWindowSize(double width, double height) async {
    await _prefs?.setDouble(_keyWindowWidth, width);
    await _prefs?.setDouble(_keyWindowHeight, height);
  }

  double? getWindowWidth() {
    return _prefs?.getDouble(_keyWindowWidth);
  }

  double? getWindowHeight() {
    return _prefs?.getDouble(_keyWindowHeight);
  }

  // Offline Mode
  Future<void> saveOfflineMode(bool isOfflineMode) async {
    await _prefs?.setBool(_keyOfflineMode, isOfflineMode);
  }

  bool getOfflineMode() {
    return _prefs?.getBool(_keyOfflineMode) ?? false;
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}

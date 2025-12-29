import 'package:get/get.dart';

import '../utils/storage_service.dart';

class LanguageController extends GetxController {
  final RxString languageCode = 'id'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final storage = await StorageService.getInstance();
    final savedLanguage = storage.getLanguageCode();
    languageCode.value = savedLanguage;
  }

  Future<void> toggleLanguage() async {
    final newLanguage = languageCode.value == 'id' ? 'en' : 'id';
    languageCode.value = newLanguage;

    // Save language preference
    final storage = await StorageService.getInstance();
    await storage.saveLanguageCode(newLanguage);
  }
}

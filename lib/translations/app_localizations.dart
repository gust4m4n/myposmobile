import '../translations/en.dart' as en_translations;
import '../translations/id.dart' as id_translations;
import '../translations/translation_extension.dart';

class AppLocalizations {
  final String languageCode;
  late final Map<String, String> _translations;

  AppLocalizations(this.languageCode) {
    // Set global language code
    TranslationService.setLanguage(languageCode);

    _translations = languageCode == 'en'
        ? en_translations.en
        : id_translations.id;
  }

  static AppLocalizations of(String languageCode) {
    return AppLocalizations(languageCode);
  }

  String _translate(String key) => _translations[key] ?? key;

  // App Title
  String get appTitle => _translate('appTitle');

  // Categories
  String get all => _translate('all');
  String get food => _translate('food');
  String get drinks => _translate('drinks');

  // Products
  String get friedRice => _translate('friedRice');
  String get friedNoodles => _translate('friedNoodles');
  String get friedChicken => _translate('friedChicken');
  String get chickenSatay => _translate('chickenSatay');
  String get icedTea => _translate('icedTea');
  String get orangeJuice => _translate('orangeJuice');
  String get coffee => _translate('coffee');
  String get avocadoJuice => _translate('avocadoJuice');

  // Cart
  String get cart => _translate('cart');
  String get emptyCart => _translate('emptyCart');
  String get total => _translate('total');
  String get checkout => _translate('checkout');
  String get retry => _translate('retry');

  // Checkout Dialog
  String get checkoutTitle => _translate('checkoutTitle');
  String totalPayment(String amount) =>
      _translate('totalPayment').replaceAll('{amount}', amount);
  String get cancel => _translate('cancel');
  String get pay => _translate('pay');
  String get transactionSuccess => _translate('transactionSuccess');

  // Theme
  String get lightMode => _translate('lightMode');
  String get darkMode => _translate('darkMode');

  // Language
  String get english => _translate('english');
  String get indonesian => _translate('indonesian');
  String get language => _translate('language');

  // Sidebar
  String get profile => _translate('profile');
  String get orders => _translate('orders');
  String get payments => _translate('payments');
  String get logout => _translate('logout');
  String get logoutConfirmation => _translate('logoutConfirmation');

  // Orders
  String get noOrders => _translate('noOrders');
  String get orderDetails => _translate('orderDetails');
  String get orderItems => _translate('orderItems');
  String get orderId => _translate('orderId');
  String get close => _translate('close');
  String get price => _translate('price');

  // Payments
  String get noPayments => _translate('noPayments');
  String get method => _translate('method');

  // Login
  String get login => _translate('login');
  String get tenantCode => _translate('tenantCode');
  String get branchCode => _translate('branchCode');
  String get username => _translate('username');
  String get password => _translate('password');
  String get loginButton => _translate('loginButton');
  String get loggingIn => _translate('loggingIn');
  String get loginSuccess => _translate('loginSuccess');
  String get loginFailed => _translate('loginFailed');
  String get pleaseEnterTenantCode => _translate('pleaseEnterTenantCode');
  String get pleaseEnterBranchCode => _translate('pleaseEnterBranchCode');
  String get pleaseEnterUsername => _translate('pleaseEnterUsername');
  String get pleaseEnterPassword => _translate('pleaseEnterPassword');
}

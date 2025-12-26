import 'package:flutter/material.dart';
import 'package:myposmobile/shared/widgets/button_x.dart';

import '../change-password/change_password_dialog.dart';
import '../faq/faq_page.dart';
import '../orders/orders_page.dart';
import '../orders/orders_service.dart';
import '../payments/payments_page.dart';
import '../payments/payments_service.dart';
import '../profile/profile_page.dart';
import '../profile/profile_service.dart';
import '../shared/api_models.dart';
import '../shared/utils/currency_formatter.dart';
import '../shared/widgets/app_bar_x.dart';
import '../shared/widgets/dialog_x.dart';
import '../tnc/tnc_page.dart';
import '../translations/translation_extension.dart';
import 'checkout_dialog.dart';
import 'payment_success_dialog.dart';
import 'product_model.dart';
import 'product_widgets.dart';
import 'products_service.dart';

class HomePage extends StatefulWidget {
  final String languageCode;
  final VoidCallback onLanguageToggle;
  final VoidCallback onLogout;

  const HomePage({
    super.key,
    required this.languageCode,
    required this.onLanguageToggle,
    required this.onLogout,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<CartItemModel> _cart = [];
  String? _selectedCategory;
  List<ProductModel> _products = [];
  List<String> _categories = [];
  bool _isLoading = false;
  final _profileService = ProfileService();
  ProfileModel? _profile;
  String _appTitle = 'MyPOSMobile';

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadProducts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload profile every time the page appears
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final response = await _profileService.getProfile();

    if (!mounted) return;

    if (response.statusCode == 200 && response.data != null) {
      setState(() {
        _profile = response.data;
        _appTitle = '${_profile!.tenant.name} - ${_profile!.branch.name}';
      });
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    final response = await ProductsService.getProducts();

    if (!mounted) return;

    if (response.statusCode == 200 && response.data != null) {
      setState(() {
        _products = response.data!
            .map((json) => ProductModel.fromJson(json))
            .toList();
        _extractCategories();
      });
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _extractCategories() {
    TranslationService.setLanguage(widget.languageCode);
    final categorySet = _products.map((p) => p.category).toSet();
    _categories = ['all'.tr, ...categorySet];
  }

  String get selectedCategory {
    TranslationService.setLanguage(widget.languageCode);
    return _selectedCategory ?? 'all'.tr;
  }

  List<ProductModel> get _filteredProducts {
    TranslationService.setLanguage(widget.languageCode);
    if (selectedCategory == 'all'.tr) {
      return _products;
    }
    return _products.where((p) => p.category == selectedCategory).toList();
  }

  void _addToCart(ProductModel product) {
    setState(() {
      final existingItem = _cart.firstWhere(
        (item) => item.product.name == product.name,
        orElse: () => CartItemModel(product: product, quantity: 0),
      );

      if (existingItem.quantity == 0) {
        _cart.add(CartItemModel(product: product));
      } else {
        existingItem.quantity++;
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      if (_cart[index].quantity > 1) {
        _cart[index].quantity--;
      } else {
        _cart.removeAt(index);
      }
    });
  }

  double get _totalPrice {
    return _cart.fold(0, (sum, item) => sum + item.total);
  }

  void _checkout() {
    if (_cart.isEmpty) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CheckoutDialog(
          languageCode: widget.languageCode,
          cart: _cart,
          totalPrice: _totalPrice,
          onCancel: () => Navigator.pop(context),
          onProcessCheckout: _processCheckout,
        );
      },
    );
  }

  Future<void> _processCheckout(String paymentMethod) async {
    TranslationService.setLanguage(widget.languageCode);

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Prepare order items
    final items = _cart.map((cartItem) {
      return {'product_id': cartItem.product.id, 'quantity': cartItem.quantity};
    }).toList();

    // Create order
    final orderResponse = await OrdersService.createOrder(
      items: items,
      notes: 'POS Order',
    );

    if (!mounted) {
      return;
    }

    if (orderResponse.statusCode == 200 && orderResponse.data != null) {
      final orderId = orderResponse.data!['id'];
      final totalAmount = _totalPrice;

      // Create payment
      final paymentResponse = await PaymentsService.createPayment(
        orderId: orderId,
        amount: totalAmount,
        paymentMethod: paymentMethod,
        notes: 'POS Payment - $paymentMethod',
      );

      if (!mounted) {
        return;
      }

      // Close loading dialog first
      Navigator.pop(context);

      if (paymentResponse.statusCode == 200) {
        // Prepare items data from cart before clearing
        final completedItems = _cart.map((cartItem) {
          return {
            'product_name': cartItem.product.name,
            'quantity': cartItem.quantity,
            'price': cartItem.product.price,
            'subtotal': cartItem.total,
          };
        }).toList();

        // Clear cart
        setState(() {
          _cart.clear();
        });

        // Show success dialog with receipt
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => PaymentSuccessDialog(
            orderData: orderResponse.data!,
            items: completedItems,
          ),
        );
      } else {
        // Payment failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(paymentResponse.message ?? 'paymentFailed'.tr),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Order failed
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(orderResponse.message ?? 'orderFailed'.tr),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return _buildCartContent(scrollController: scrollController);
        },
      ),
    );
  }

  Widget _buildCartContent({ScrollController? scrollController}) {
    final theme = Theme.of(context);
    TranslationService.setLanguage(widget.languageCode);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart),
                const SizedBox(width: 8),
                Text(
                  'cart'.tr,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (scrollController != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'emptyCart'.tr,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: _cart.length,
                    itemBuilder: (context, index) {
                      final item = _cart[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          border: Border(
                            bottom: BorderSide(
                              color: theme.dividerColor,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Text(
                            item.product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          subtitle: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: CurrencyFormatter.format(
                                    item.product.price,
                                  ),
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: ' x ',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 16.0,
                                  ),
                                ),
                                TextSpan(
                                  text: '${item.quantity}',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                CurrencyFormatter.format(item.total),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                color: theme.colorScheme.error,
                                onPressed: () {
                                  setState(() {
                                    _removeFromCart(index);
                                  });
                                  Navigator.pop(context);
                                  if (_cart.isNotEmpty) {
                                    _showCartBottomSheet(context);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(
                top: BorderSide(color: theme.dividerColor, width: 1),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'total'.tr,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(_totalPrice),
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _cart.isEmpty ? null : _checkout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'checkout'.tr,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrDesktop = screenWidth >= 768;
    final theme = Theme.of(context);
    TranslationService.setLanguage(widget.languageCode);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawerScrimColor: Colors.black54,
      drawerEnableOpenDragGesture: false,
      appBar: AppBarX(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          tooltip: 'Menu',
        ),
        title: Row(
          children: [
            Icon(
              Icons.store,
              size: 24,
              color: theme.appBarTheme.foregroundColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _appTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.language),
              tooltip: 'language'.tr,
              onSelected: (value) {
                widget.onLanguageToggle();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'en',
                  child: Row(
                    children: [
                      if (widget.languageCode == 'en')
                        const Icon(Icons.check, size: 20)
                      else
                        const SizedBox(width: 20),
                      const SizedBox(width: 8),
                      Text('english'.tr),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'id',
                  child: Row(
                    children: [
                      if (widget.languageCode == 'id')
                        const Icon(Icons.check, size: 20)
                      else
                        const SizedBox(width: 20),
                      const SizedBox(width: 8),
                      Text('indonesian'.tr),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!isTabletOrDesktop)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () => _showCartBottomSheet(context),
                ),
                if (_cart.isNotEmpty)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        '${_cart.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : isTabletOrDesktop
          ? Row(
              children: [
                // Produk Section
                Expanded(
                  flex: 2,
                  child: ProductsWidget(
                    products: _filteredProducts,
                    selectedCategory: selectedCategory,
                    categories: _categories,
                    onCategorySelected: (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    onProductTap: _addToCart,
                    isMobile: false,
                  ),
                ),

                // Cart Section
                Container(
                  width: 350,
                  decoration: BoxDecoration(
                    color: const Color(0xFF000000),
                    border: Border(left: BorderSide(color: theme.dividerColor)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: theme.cardColor,
                        child: Row(
                          children: [
                            const Icon(Icons.shopping_cart),
                            const SizedBox(width: 8),
                            Text(
                              'cart'.tr,
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _cart.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.shopping_cart_outlined,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'emptyCart'.tr,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                physics: const ClampingScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: _cart.length,
                                itemBuilder: (context, index) {
                                  final item = _cart[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: theme.cardColor,
                                      border: Border(
                                        bottom: BorderSide(
                                          color: theme.dividerColor,
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                      title: Text(
                                        item.product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                      subtitle: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: CurrencyFormatter.format(
                                                item.product.price,
                                              ),
                                              style: TextStyle(
                                                color: Colors.orange.shade700,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text: ' x ',
                                              style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                            TextSpan(
                                              text: '${item.quantity}',
                                              style: TextStyle(
                                                color:
                                                    theme.colorScheme.primary,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            CurrencyFormatter.format(
                                              item.total,
                                            ),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.remove_circle_outline,
                                            ),
                                            color: theme.colorScheme.error,
                                            onPressed: () =>
                                                _removeFromCart(index),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          border: Border(
                            top: BorderSide(
                              color: theme.dividerColor,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'total'.tr,
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.format(_totalPrice),
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _cart.isEmpty ? null : _checkout,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'checkout'.tr,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : ProductsWidget(
              products: _filteredProducts,
              selectedCategory: selectedCategory,
              categories: _categories,
              onCategorySelected: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              onProductTap: _addToCart,
              isMobile: true,
            ),
      floatingActionButton: !isTabletOrDesktop && _cart.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showCartBottomSheet(context),
              backgroundColor: Colors.blue,
              icon: Stack(
                children: [
                  const Icon(Icons.shopping_cart),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${_cart.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              label: Text(
                CurrencyFormatter.format(_totalPrice),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
      drawer: Drawer(
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Container(
          color: theme.scaffoldBackgroundColor,
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const ClampingScrollPhysics(),
            children: [
              Container(
                color: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 24,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _profile?.user.fullName ?? 'User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.person_outline,
                  color: theme.colorScheme.onSurface,
                ),
                title: Text(
                  'profile'.tr,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProfilePage(languageCode: widget.languageCode),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.lock_outline,
                  color: theme.colorScheme.onSurface,
                ),
                title: Text(
                  'changePassword'.tr,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) =>
                        ChangePasswordDialog(languageCode: widget.languageCode),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.shopping_bag_outlined,
                  color: theme.colorScheme.onSurface,
                ),
                title: Text(
                  'orders'.tr,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OrdersPage(languageCode: widget.languageCode),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.payment_outlined,
                  color: theme.colorScheme.onSurface,
                ),
                title: Text(
                  'payments'.tr,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PaymentsPage(languageCode: widget.languageCode),
                    ),
                  );
                },
              ),
              Divider(color: theme.dividerColor, height: 1),
              ListTile(
                leading: Icon(
                  Icons.help_outline,
                  color: theme.colorScheme.onSurface,
                ),
                title: Text(
                  'faq'.tr,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FaqPage(languageCode: widget.languageCode),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.description_outlined,
                  color: theme.colorScheme.onSurface,
                ),
                title: Text(
                  'termsAndConditions'.tr,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TncPage(languageCode: widget.languageCode),
                    ),
                  );
                },
              ),
              Divider(color: theme.dividerColor, height: 1),
              ListTile(
                leading: Icon(Icons.logout, color: theme.colorScheme.error),
                title: Text(
                  'logout'.tr,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: theme.colorScheme.error,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  // Show confirmation dialog
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => DialogX(
                      title: 'logout'.tr,
                      width: 400,
                      onClose: () => Navigator.pop(context, false),
                      content: Text('logoutConfirmation'.tr),
                      actions: [
                        ButtonX(
                          onPressed: () => Navigator.pop(context, false),
                          icon: Icons.cancel,
                          label: 'cancel'.tr,
                          backgroundColor: theme.colorScheme.surface,
                          foregroundColor: theme.colorScheme.onSurface,
                        ),
                        ButtonX(
                          onPressed: () => Navigator.pop(context, true),
                          icon: Icons.logout,
                          label: 'logout'.tr,
                          backgroundColor: theme.colorScheme.error,
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    widget.onLogout();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

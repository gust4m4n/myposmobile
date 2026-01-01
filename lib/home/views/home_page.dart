import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:myposmobile/shared/widgets/button_x.dart';

import '../../audit-trails/views/audit_trails_page.dart';
import '../../branches/views/branches_management_page.dart';
import '../../change-password/views/change_password_dialog.dart';
import '../../faq/views/faq_page.dart';
import '../../orders/services/orders_service.dart';
import '../../orders/views/orders_page.dart';
import '../../payments/services/payments_service.dart';
import '../../payments/views/payment_detail_dialog.dart';
import '../../payments/views/payments_page.dart';
import '../../pin/services/pin_service.dart';
import '../../pin/views/pin_dialog.dart';
import '../../products/views/products_management_page.dart';
import '../../profile/services/profile_service.dart';
import '../../profile/views/profile_page.dart';
import '../../shared/api_models.dart';
import '../../shared/controllers/auth_controller.dart';
import '../../shared/controllers/language_controller.dart';
import '../../shared/controllers/profile_controller.dart';
import '../../shared/utils/currency_formatter.dart';
import '../../shared/widgets/app_bar_x.dart';
import '../../shared/widgets/connectivity_indicator.dart';
import '../../shared/widgets/dialog_x.dart';
import '../../shared/widgets/toast_x.dart';
import '../../tenants/views/tenants_management_page.dart';
import '../../tnc/views/tnc_page.dart';
import '../../translations/translation_extension.dart';
import '../../users/views/users_management_page.dart';
import '../models/product_model.dart';
import '../services/products_service.dart';
import 'checkout_dialog.dart';
import 'product_widgets.dart';

class HomePage extends StatefulWidget {
  final String languageCode;

  const HomePage({super.key, required this.languageCode});

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
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  final int _pageSize = 32;
  final _profileService = ProfileService();
  ProfileModel? _profile;
  String _appTitle = 'MyPOSMobile';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreProducts();
      }
    }
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
      _currentPage = 1;
      _hasMoreData = true;
    });

    final response = await ProductsService.getProducts(
      category: _selectedCategory == 'all'.tr ? null : _selectedCategory,
      page: _currentPage,
      pageSize: _pageSize,
    );

    if (!mounted) return;

    if (response.statusCode == 200 && response.data != null) {
      setState(() {
        _products = response.data!
            .map((json) => ProductModel.fromJson(json))
            .toList();
        _hasMoreData = response.data!.length >= _pageSize;
        // Only extract categories on first load (when category list is empty)
        if (_categories.isEmpty) {
          _extractCategories();
        }
      });
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    _currentPage++;
    final response = await ProductsService.getProducts(
      category: _selectedCategory == 'all'.tr ? null : _selectedCategory,
      page: _currentPage,
      pageSize: _pageSize,
    );

    if (!mounted) return;

    if (response.statusCode == 200 && response.data != null) {
      final newProducts = response.data!
          .map((json) => ProductModel.fromJson(json))
          .toList();
      setState(() {
        _products.addAll(newProducts);
        _hasMoreData = newProducts.length >= _pageSize;
        _isLoadingMore = false;
      });
    } else {
      setState(() {
        _isLoadingMore = false;
        _currentPage--;
      });
    }
  }

  void _extractCategories() {
    TranslationService.setLanguage(widget.languageCode);
    // Load all products without filter to get all categories
    ProductsService.getProducts(page: 1, pageSize: 1000).then((response) {
      if (response.statusCode == 200 && response.data != null) {
        final allProducts = response.data!
            .map((json) => ProductModel.fromJson(json))
            .toList();
        final categorySet = allProducts.map((p) => p.category).toSet();
        if (mounted) {
          setState(() {
            _categories = ['all'.tr, ...categorySet];
          });
        }
      }
    });
  }

  String get selectedCategory {
    TranslationService.setLanguage(widget.languageCode);
    return _selectedCategory ?? 'all'.tr;
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
      _currentPage = 1;
      _hasMoreData = true;
    });
    _loadProducts();
  }

  List<ProductModel> get _filteredProducts {
    return _products;
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
        // Clear cart
        setState(() {
          _cart.clear();
        });

        // Show success dialog with receipt
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => PaymentDetailDialog(
            payment: paymentResponse.data!,
            languageCode: widget.languageCode,
            orderData: orderResponse.data!,
            isSuccessMode: true,
          ),
        );
      } else {
        // Payment failed
        ToastX.error(context, paymentResponse.message ?? 'paymentFailed'.tr);
      }
    } else {
      // Order failed
      if (mounted) {
        Navigator.pop(context);
        ToastX.error(context, orderResponse.message ?? 'orderFailed'.tr);
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
                  child: ButtonX(
                    onPressed: _cart.isEmpty ? null : _checkout,
                    icon: Icons.shopping_cart_checkout,
                    label: 'checkout'.tr,
                    backgroundColor: theme.colorScheme.primary,
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
          tooltip: 'menu'.tr,
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
          const ConnectivityIndicator(),
          // User Profile Photo
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProfilePage(languageCode: widget.languageCode),
                ),
              );
              // Reload profile when returning from profile page
              _loadProfile();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: theme.colorScheme.primary,
                backgroundImage:
                    _profile?.user.image != null &&
                        _profile!.user.image!.isNotEmpty
                    ? NetworkImage(
                        _profile!.user.image!.startsWith('http')
                            ? _profile!.user.image!
                            : 'http://localhost:8080${_profile!.user.image!}',
                      )
                    : null,
                child:
                    _profile?.user.image == null ||
                        _profile!.user.image!.isEmpty
                    ? const Icon(Icons.person, size: 20, color: Colors.white)
                    : null,
              ),
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
                  child: Column(
                    children: [
                      Expanded(
                        child: ProductsWidget(
                          products: _filteredProducts,
                          selectedCategory: selectedCategory,
                          categories: _categories,
                          onCategorySelected: _onCategoryChanged,
                          onProductTap: _addToCart,
                          isMobile: false,
                          scrollController: _scrollController,
                        ),
                      ),
                      if (_isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                    ],
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
                              child: ButtonX(
                                onPressed: _cart.isEmpty ? null : _checkout,
                                icon: Icons.shopping_cart_checkout,
                                label: 'checkout'.tr,
                                backgroundColor: theme.colorScheme.primary,
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
          : Column(
              children: [
                Expanded(
                  child: ProductsWidget(
                    products: _filteredProducts,
                    selectedCategory: selectedCategory,
                    categories: _categories,
                    onCategorySelected: _onCategoryChanged,
                    onProductTap: _addToCart,
                    isMobile: true,
                    scrollController: _scrollController,
                  ),
                ),
                if (_isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
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
                        _profile?.user.fullName ?? 'user'.tr,
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
                  Icons.pin_outlined,
                  color: theme.colorScheme.onSurface,
                ),
                title: Text(
                  'changePin'.tr,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  // Check if user has PIN
                  final statusResponse = await PinService.checkPinStatus();
                  final hasPin =
                      statusResponse.statusCode == 200 &&
                      statusResponse.data?['has_pin'] == true;

                  if (!mounted) return;

                  showDialog(
                    context: context,
                    builder: (context) => PinDialog(
                      languageCode: widget.languageCode,
                      hasExistingPin: hasPin,
                    ),
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
              ListTile(
                leading: Icon(
                  Icons.inventory_2_outlined,
                  color: theme.colorScheme.onSurface,
                ),
                title: Text(
                  'productsManagement'.tr,
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
                      builder: (context) => ProductsManagementPage(
                        languageCode: widget.languageCode,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.people_outline,
                  color: theme.colorScheme.onSurface,
                ),
                title: Text(
                  'userManagement'.tr,
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
                      builder: (context) => UsersManagementPage(
                        languageCode: widget.languageCode,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.history,
                  color: theme.colorScheme.onSurface,
                ),
                title: Text(
                  'auditTrails'.tr,
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
                          AuditTrailsPage(languageCode: widget.languageCode),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.business,
                  color: theme.colorScheme.onSurface,
                ),
                title: Text(
                  'tenantsManagement'.tr,
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
                      builder: (context) => TenantsManagementPage(
                        languageCode: widget.languageCode,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.store, color: theme.colorScheme.onSurface),
                title: Text(
                  'branchesManagement'.tr,
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
                      builder: (context) => BranchesManagementPage(
                        languageCode: widget.languageCode,
                      ),
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
                leading: Icon(
                  Icons.language,
                  color: theme.colorScheme.onSurface,
                ),
                title: Row(
                  children: [
                    Text(
                      'language'.tr,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.languageCode == 'en' ? '(English)' : '(Indonesia)',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                onTap: () async {
                  Navigator.pop(context);
                  // Show language selection dialog
                  final selectedLanguage = await showDialog<String>(
                    context: context,
                    builder: (context) => DialogX(
                      title: 'selectLanguage'.tr,
                      width: 400,
                      onClose: () => Navigator.pop(context),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: widget.languageCode == 'en'
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                : const Icon(Icons.circle_outlined),
                            title: Text('english'.tr),
                            onTap: () => Navigator.pop(context, 'en'),
                            selected: widget.languageCode == 'en',
                          ),
                          ListTile(
                            leading: widget.languageCode == 'id'
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                : const Icon(Icons.circle_outlined),
                            title: Text('indonesian'.tr),
                            onTap: () => Navigator.pop(context, 'id'),
                            selected: widget.languageCode == 'id',
                          ),
                        ],
                      ),
                      actions: [
                        ButtonX(
                          onPressed: () => Navigator.pop(context),
                          icon: Icons.close,
                          label: 'close'.tr,
                          backgroundColor: theme.colorScheme.surface,
                          foregroundColor: theme.colorScheme.onSurface,
                        ),
                      ],
                    ),
                  );

                  if (selectedLanguage != null &&
                      selectedLanguage != widget.languageCode) {
                    Get.find<LanguageController>().toggleLanguage();
                  }
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
                    final authController = Get.find<AuthController>();
                    final profileController = Get.find<ProfileController>();
                    await authController.logout();
                    profileController.clearProfile();
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

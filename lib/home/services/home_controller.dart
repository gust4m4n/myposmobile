import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../home/models/product_model.dart';
import '../../home/services/products_service.dart';
import '../../shared/controllers/profile_controller.dart';

class HomeController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final RxList<CartItemModel> cart = <CartItemModel>[].obs;
  final Rx<String?> selectedCategory = Rx<String?>(null);
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<String> categories = <String>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();

    // Fetch profile when home loads
    final profileController = Get.find<ProfileController>();
    profileController.fetchProfile();
  }

  Future<void> loadProducts() async {
    isLoading.value = true;

    final response = await ProductsService.getProducts();

    if (response.statusCode == 200 && response.data != null) {
      products.value = response.data!
          .map((json) => ProductModel.fromJson(json))
          .toList();
      extractCategories();
    }

    isLoading.value = false;
  }

  void extractCategories() {
    final categorySet = products.map((p) => p.category).toSet();
    categories.value = ['All', ...categorySet];
  }

  List<ProductModel> get filteredProducts {
    if (selectedCategory.value == null || selectedCategory.value == 'All') {
      return products;
    }
    return products.where((p) => p.category == selectedCategory.value).toList();
  }

  void addToCart(ProductModel product) {
    final index = cart.indexWhere((item) => item.product.name == product.name);

    if (index >= 0) {
      cart[index].quantity++;
      cart.refresh(); // Notify observers
    } else {
      cart.add(CartItemModel(product: product));
    }
  }

  void removeFromCart(int index) {
    if (cart[index].quantity > 1) {
      cart[index].quantity--;
      cart.refresh(); // Notify observers
    } else {
      cart.removeAt(index);
    }
  }

  void clearCart() {
    cart.clear();
  }

  double get totalAmount {
    return cart.fold(
      0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
  }

  int get totalItems {
    return cart.fold(0, (sum, item) => sum + item.quantity);
  }
}

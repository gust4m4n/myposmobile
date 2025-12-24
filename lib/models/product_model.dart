class ProductModel {
  final String name;
  final double price;
  final String category;

  ProductModel({
    required this.name,
    required this.price,
    required this.category,
  });
}

class CartItemModel {
  final ProductModel product;
  int quantity;

  CartItemModel({required this.product, this.quantity = 1});

  double get total => product.price * quantity;
}

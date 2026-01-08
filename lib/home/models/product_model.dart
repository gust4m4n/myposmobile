class ProductModel {
  final int? id;
  final String name;
  final double price;
  final String category;
  final int? categoryId;
  final Map<String, dynamic>? categoryDetail;
  final String? description;
  final String? sku;
  final int? stock;
  final bool? isActive;
  final String? image;

  ProductModel({
    this.id,
    required this.name,
    required this.price,
    required this.category,
    this.categoryId,
    this.categoryDetail,
    this.description,
    this.sku,
    this.stock,
    this.isActive,
    this.image,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : json['price'] as double,
      category: json['category'] as String,
      categoryId: json['category_id'] as int?,
      categoryDetail: json['category_detail'] as Map<String, dynamic>?,
      description: json['description'] as String?,
      sku: json['sku'] as String?,
      stock: json['stock'] as int?,
      isActive: json['is_active'] as bool?,
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'price': price,
      'category': category,
      if (categoryId != null) 'category_id': categoryId,
      if (description != null) 'description': description,
      if (sku != null) 'sku': sku,
      if (stock != null) 'stock': stock,
      if (isActive != null) 'is_active': isActive,
      if (image != null) 'image': image,
    };
  }
}

class CartItemModel {
  final ProductModel product;
  int quantity;

  CartItemModel({required this.product, this.quantity = 1});

  double get total => product.price * quantity;
}

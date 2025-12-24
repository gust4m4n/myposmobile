import 'dart:convert';

import '../config/api_config.dart';
import '../models/api_models.dart';
import '../utils/http_client.dart';

/// Service untuk operasi produk (CRUD dan categories).
/// Memerlukan JWT token untuk authentication.
/// Produk yang ditampilkan sesuai dengan tenant dan branch dari user yang login.
class ProductsService {
  /// Get list of products with optional filters
  ///
  /// Memerlukan JWT token di header Authorization.
  /// Products yang ditampilkan sesuai tenant & branch user yang sedang login.
  ///
  /// Parameters:
  /// - category: Filter by exact category name (optional)
  /// - search: Search keyword in name, description, or SKU (optional)
  ///
  /// Returns:
  /// - List<Map<String, dynamic>> berisi data products
  ///
  /// Example:
  /// ```dart
  /// // Get all products
  /// final result = await ProductsService.getProducts();
  ///
  /// // Filter by category
  /// final drinks = await ProductsService.getProducts(category: 'Minuman');
  ///
  /// // Search products
  /// final searchResult = await ProductsService.getProducts(search: 'ayam');
  ///
  /// // Combined filters
  /// final filtered = await ProductsService.getProducts(
  ///   category: 'Makanan Utama',
  ///   search: 'goreng'
  /// );
  /// ```
  static Future<ApiResponse<List<Map<String, dynamic>>>> getProducts({
    String? category,
    String? search,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{};
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      // Build URL with query params
      var url = ApiConfig.products;
      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map(
              (e) =>
                  '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
            )
            .join('&');
        url = '$url?$queryString';
      }

      final response = await HttpClient().get(url, requiresAuth: true);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = (data['data'] as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();

        return ApiResponse<List<Map<String, dynamic>>>(
          data: products,
          message: data['message'] ?? 'Products retrieved successfully',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse<List<Map<String, dynamic>>>(
          error: errorData['error'] ?? 'Failed to get products',
        );
      }
    } catch (e) {
      return ApiResponse<List<Map<String, dynamic>>>(
        error: 'Error getting products: $e',
      );
    }
  }

  /// Get product by ID
  ///
  /// Parameters:
  /// - productId: ID of the product
  ///
  /// Returns:
  /// - Map<String, dynamic> berisi detail product
  ///
  /// Example:
  /// ```dart
  /// final result = await ProductsService.getProductById(1);
  /// ```
  static Future<ApiResponse<Map<String, dynamic>>> getProductById(
    int productId,
  ) async {
    try {
      final response = await HttpClient().get(
        '${ApiConfig.products}/$productId',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          data: data['data'] as Map<String, dynamic>,
          message: data['message'] ?? 'Product retrieved successfully',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          error: errorData['error'] ?? 'Failed to get product',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        error: 'Error getting product: $e',
      );
    }
  }

  /// Get list of unique product categories
  ///
  /// Returns:
  /// - List<String> berisi daftar kategori unik
  ///
  /// Example:
  /// ```dart
  /// final result = await ProductsService.getCategories();
  /// // result.data = ["Makanan Utama", "Minuman", "Snack & Dessert"]
  /// ```
  static Future<ApiResponse<List<String>>> getCategories() async {
    try {
      final response = await HttpClient().get(
        '${ApiConfig.products}/categories',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final categories = (data['data'] as List)
            .map((item) => item.toString())
            .toList();

        return ApiResponse<List<String>>(
          data: categories,
          message: data['message'] ?? 'Categories retrieved successfully',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse<List<String>>(
          error: errorData['error'] ?? 'Failed to get categories',
        );
      }
    } catch (e) {
      return ApiResponse<List<String>>(error: 'Error getting categories: $e');
    }
  }

  /// Create new product
  ///
  /// Parameters:
  /// - name: Product name (required)
  /// - description: Product description (optional)
  /// - category: Product category (required)
  /// - sku: Product SKU (required)
  /// - price: Product price (required)
  /// - stock: Product stock (required)
  /// - isActive: Product active status (default: true)
  ///
  /// Returns:
  /// - Map<String, dynamic> berisi data product yang dibuat
  ///
  /// Example:
  /// ```dart
  /// final result = await ProductsService.createProduct(
  ///   name: 'Produk Baru',
  ///   category: 'Makanan Utama',
  ///   sku: 'SKU-001',
  ///   price: 50000,
  ///   stock: 100,
  /// );
  /// ```
  static Future<ApiResponse<Map<String, dynamic>>> createProduct({
    required String name,
    String? description,
    required String category,
    required String sku,
    required double price,
    required int stock,
    bool isActive = true,
  }) async {
    try {
      final response = await HttpClient().post(
        ApiConfig.products,
        body: {
          'name': name,
          if (description != null) 'description': description,
          'category': category,
          'sku': sku,
          'price': price,
          'stock': stock,
          'is_active': isActive,
        },
        requiresAuth: true,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          data: data['data'] as Map<String, dynamic>,
          message: data['message'] ?? 'Product created successfully',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          error: errorData['error'] ?? 'Failed to create product',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        error: 'Error creating product: $e',
      );
    }
  }

  /// Update existing product
  ///
  /// Parameters:
  /// - productId: ID of the product to update
  /// - name: Product name (optional)
  /// - description: Product description (optional)
  /// - category: Product category (optional)
  /// - sku: Product SKU (optional)
  /// - price: Product price (optional)
  /// - stock: Product stock (optional)
  /// - isActive: Product active status (optional)
  ///
  /// Returns:
  /// - Map<String, dynamic> berisi data product yang diupdate
  ///
  /// Example:
  /// ```dart
  /// final result = await ProductsService.updateProduct(
  ///   productId: 1,
  ///   name: 'Produk Updated',
  ///   price: 75000,
  /// );
  /// ```
  static Future<ApiResponse<Map<String, dynamic>>> updateProduct({
    required int productId,
    String? name,
    String? description,
    String? category,
    String? sku,
    double? price,
    int? stock,
    bool? isActive,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (description != null) body['description'] = description;
      if (category != null) body['category'] = category;
      if (sku != null) body['sku'] = sku;
      if (price != null) body['price'] = price;
      if (stock != null) body['stock'] = stock;
      if (isActive != null) body['is_active'] = isActive;

      final response = await HttpClient().put(
        '${ApiConfig.products}/$productId',
        body: body,
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          data: data['data'] as Map<String, dynamic>,
          message: data['message'] ?? 'Product updated successfully',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          error: errorData['error'] ?? 'Failed to update product',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        error: 'Error updating product: $e',
      );
    }
  }

  /// Delete product
  ///
  /// Parameters:
  /// - productId: ID of the product to delete
  ///
  /// Returns:
  /// - bool berisi status penghapusan
  ///
  /// Example:
  /// ```dart
  /// final result = await ProductsService.deleteProduct(1);
  /// ```
  static Future<ApiResponse<bool>> deleteProduct(int productId) async {
    try {
      final response = await HttpClient().delete(
        '${ApiConfig.products}/$productId',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse<bool>(
          data: true,
          message: data['message'] ?? 'Product deleted successfully',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse<bool>(
          error: errorData['error'] ?? 'Failed to delete product',
        );
      }
    } catch (e) {
      return ApiResponse<bool>(error: 'Error deleting product: $e');
    }
  }
}

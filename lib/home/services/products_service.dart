import 'dart:io';

import '../../shared/api_models.dart';
import '../../shared/utils/api_x.dart';

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
  static Future<ApiResponse<PaginatedResponse<Map<String, dynamic>>>>
  getProducts({
    String? category,
    String? search,
    int? page,
    int? pageSize,
  }) async {
    // Build query parameters
    final queryParams = <String, String>{};
    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (page != null) {
      queryParams['page'] = page.toString();
    }
    if (pageSize != null) {
      queryParams['page_size'] = pageSize.toString();
    }

    // Build URL with query params
    var url = '/products';
    if (queryParams.isNotEmpty) {
      final queryString = queryParams.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
          )
          .join('&');
      url = '$url?$queryString';
    }

    // Get raw response without fromJson transformation
    final response = await ApiX.get<dynamic>(url, requiresAuth: true);

    // Manually transform response to PaginatedResponse
    if (response.data != null && response.data is Map) {
      final jsonData = response.data as Map<String, dynamic>;
      final paginatedData = PaginatedResponse<Map<String, dynamic>>(
        page: jsonData['page'] ?? 1,
        pageSize: jsonData['page_size'] ?? 20,
        totalItems: jsonData['total_items'] ?? 0,
        totalPages: jsonData['total_pages'] ?? 1,
        data:
            (jsonData['data'] as List<dynamic>?)
                ?.map((item) => item as Map<String, dynamic>)
                .toList() ??
            [],
      );

      return ApiResponse<PaginatedResponse<Map<String, dynamic>>>(
        code: response.code,
        message: response.message,
        data: paginatedData,
        error: response.error,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse<PaginatedResponse<Map<String, dynamic>>>(
      code: response.code,
      message: response.message,
      data: null,
      error: response.error,
      statusCode: response.statusCode,
    );
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
    return ApiX.get<Map<String, dynamic>>(
      '/products/$productId',
      requiresAuth: true,
      fromJson: (data) => data as Map<String, dynamic>,
    );
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
    return ApiX.get<List<String>>(
      '/products/categories',
      requiresAuth: true,
      fromJson: (data) =>
          (data as List).map((item) => item.toString()).toList(),
    );
  }

  /// Create new product
  ///
  /// Parameters:
  /// - name: Product name (required)
  /// - description: Product description (optional)
  /// - categoryId: Category ID (required)
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
  ///   categoryId: 13,
  ///   sku: 'SKU-001',
  ///   price: 50000,
  ///   stock: 100,
  /// );
  /// ```
  static Future<ApiResponse<Map<String, dynamic>>> createProduct({
    required String name,
    String? description,
    required int categoryId,
    required String sku,
    required double price,
    required int stock,
    bool isActive = true,
  }) async {
    return ApiX.post<Map<String, dynamic>>(
      '/products',
      body: {
        'name': name,
        if (description != null) 'description': description,
        'category_id': categoryId,
        'sku': sku,
        'price': price,
        'stock': stock,
        'is_active': isActive,
      },
      requiresAuth: true,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// Update existing product
  ///
  /// Parameters:
  /// - productId: ID of the product to update
  /// - name: Product name (optional)
  /// - description: Product description (optional)
  /// - categoryId: Category ID (optional)
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
    int? categoryId,
    String? sku,
    double? price,
    int? stock,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (categoryId != null) body['category_id'] = categoryId;
    if (sku != null) body['sku'] = sku;
    if (price != null) body['price'] = price;
    if (stock != null) body['stock'] = stock;
    if (isActive != null) body['is_active'] = isActive;

    return ApiX.put<Map<String, dynamic>>(
      '/products/$productId',
      body: body,
      requiresAuth: true,
      fromJson: (data) => data as Map<String, dynamic>,
    );
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
    return ApiX.delete<bool>(
      '/products/$productId',
      requiresAuth: true,
      fromJson: (data) => true,
    );
  }

  /// POST /api/v1/products/:id/photo
  /// Upload product image
  /// Requires JWT token in Authorization header
  ///
  /// Parameters:
  /// - productId: ID of product to upload image for
  /// - imageFile: Image file to upload (jpg, jpeg, png, gif, webp, max 5MB)
  ///
  /// Returns: Updated product with new photo URL
  static Future<ApiResponse<Map<String, dynamic>>> uploadProductImage({
    required int productId,
    required File imageFile,
  }) async {
    return await ApiX.postMultipart(
      '/products/$productId/photo',
      fields: {},
      filePath: imageFile.path,
      fileFieldName: 'image',
      requiresAuth: true,
    );
  }

  /// DELETE /api/v1/products/:id/photo
  /// Delete product image
  /// Requires JWT token in Authorization header
  ///
  /// Parameters:
  /// - productId: ID of product to delete image for
  ///
  /// Returns: Updated product without photo
  static Future<ApiResponse<Map<String, dynamic>>> deleteProductImage({
    required int productId,
  }) async {
    return await ApiX.delete(
      '/products/$productId/photo',
      requiresAuth: true,
    );
  }

  /// Get products filtered by category ID
  ///
  /// Parameters:
  /// - categoryId: ID of the category
  /// - page: Page number (optional)
  /// - pageSize: Items per page (optional)
  ///
  /// Returns:
  /// - List<Map<String, dynamic>> berisi data products in the category
  ///
  /// Example:
  /// ```dart
  /// final result = await ProductsService.getProductsByCategory(
  ///   categoryId: 13,
  ///   page: 1,
  ///   pageSize: 20,
  /// );
  /// ```
  static Future<ApiResponse<PaginatedResponse<Map<String, dynamic>>>>
  getProductsByCategory({
    required int categoryId,
    int? page,
    int? pageSize,
  }) async {
    final queryParams = <String, String>{};
    if (page != null) queryParams['page'] = page.toString();
    if (pageSize != null) queryParams['page_size'] = pageSize.toString();

    var url = '/products/by-category/$categoryId';
    if (queryParams.isNotEmpty) {
      final queryString = queryParams.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
          )
          .join('&');
      url = '$url?$queryString';
    }

    // Get raw response without fromJson transformation
    final response = await ApiX.get<dynamic>(url, requiresAuth: true);

    // Manually transform response to PaginatedResponse
    if (response.data != null && response.data is Map) {
      final jsonData = response.data as Map<String, dynamic>;
      final paginatedData = PaginatedResponse<Map<String, dynamic>>(
        page: jsonData['page'] ?? 1,
        pageSize: jsonData['page_size'] ?? 20,
        totalItems: jsonData['total_items'] ?? 0,
        totalPages: jsonData['total_pages'] ?? 1,
        data:
            (jsonData['data'] as List<dynamic>?)
                ?.map((item) => item as Map<String, dynamic>)
                .toList() ??
            [],
      );

      return ApiResponse<PaginatedResponse<Map<String, dynamic>>>(
        code: response.code,
        message: response.message,
        data: paginatedData,
        error: response.error,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse<PaginatedResponse<Map<String, dynamic>>>(
      code: response.code,
      message: response.message,
      data: null,
      error: response.error,
      statusCode: response.statusCode,
    );
  }
}

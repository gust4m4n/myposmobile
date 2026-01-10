import 'dart:io';

import '../../home/models/product_model.dart';
import '../../home/services/products_service.dart';
import '../../shared/api_models.dart';
import '../../shared/utils/api_x.dart';
import 'product_offline_service.dart';

class ProductsManagementService {
  static final ProductOfflineService _offlineService = ProductOfflineService();
  static Future<ApiResponse<Map<String, dynamic>>> createProduct({
    required String name,
    required String description,
    required int categoryId,
    required String sku,
    required double price,
    required int stock,
    required bool isActive,
  }) async {
    return await ApiX.post(
      '/products',
      body: {
        'name': name,
        'description': description,
        'category_id': categoryId,
        'sku': sku,
        'price': price,
        'stock': stock,
        'is_active': isActive,
      },
      requiresAuth: true,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> updateProduct({
    required int id,
    required String name,
    required String description,
    required int categoryId,
    required String sku,
    required double price,
    required int stock,
    required bool isActive,
  }) async {
    return await ApiX.put(
      '/products/$id',
      body: {
        'name': name,
        'description': description,
        'category_id': categoryId,
        'sku': sku,
        'price': price,
        'stock': stock,
        'is_active': isActive,
      },
      requiresAuth: true,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> deleteProduct({
    required int id,
  }) async {
    return await ApiX.delete('/products/$id', requiresAuth: true);
  }

  /// Upload product image
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

  /// Delete product image
  static Future<ApiResponse<Map<String, dynamic>>> deleteProductImage({
    required int productId,
  }) async {
    return await ApiX.delete(
      '/products/$productId/photo',
      requiresAuth: true,
    );
  }

  /// Sync products from server to local DB with large pagination
  static Future<void> syncProductsFromServer() async {
    try {
      final response = await ProductsService.getProducts(
        page: 1,
        pageSize: 999999,
      );
      if (response.statusCode == 200 && response.data != null) {
        // Convert Map<String, dynamic> to ProductModel
        final products = response.data!.data
            .map((json) => ProductModel.fromJson(json))
            .toList();
        await _offlineService.saveProducts(products);
      }
    } catch (e) {
      print('Error syncing products: $e');
      rethrow;
    }
  }
}

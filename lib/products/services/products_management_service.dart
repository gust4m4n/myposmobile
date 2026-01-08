import 'dart:io';

import '../../shared/api_models.dart';
import '../../shared/config/api_config.dart';
import '../../shared/utils/api_x.dart';

class ProductsManagementService {
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
      ApiConfig.products,
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
      '${ApiConfig.products}/$id',
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
    return await ApiX.delete('${ApiConfig.products}/$id', requiresAuth: true);
  }

  /// Upload product image
  static Future<ApiResponse<Map<String, dynamic>>> uploadProductImage({
    required int productId,
    required File imageFile,
  }) async {
    return await ApiX.postMultipart(
      '${ApiConfig.products}/$productId/photo',
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
      '${ApiConfig.products}/$productId/photo',
      requiresAuth: true,
    );
  }
}

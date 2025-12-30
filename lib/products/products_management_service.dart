import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../shared/api_models.dart';
import '../shared/config/api_config.dart';
import '../shared/utils/api_x.dart';
import '../shared/utils/storage_service.dart';

class ProductsManagementService {
  static Future<ApiResponse<Map<String, dynamic>>> createProduct({
    required String name,
    required String description,
    required String category,
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
        'category': category,
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
    required String category,
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
        'category': category,
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
    try {
      final storage = await StorageService.getInstance();
      final token = storage.getToken();

      if (token == null) {
        return ApiResponse<Map<String, dynamic>>(
          error: 'No authentication token',
          statusCode: 401,
        );
      }

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.products}/$productId/photo',
      );
      final request = http.MultipartRequest('POST', uri);

      // Add auth header
      request.headers['Authorization'] = 'Bearer $token';

      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body) as Map<String, dynamic>;
          return ApiResponse<Map<String, dynamic>>(
            data: data,
            statusCode: response.statusCode,
          );
        } catch (e) {
          return ApiResponse<Map<String, dynamic>>(
            data: {},
            statusCode: response.statusCode,
          );
        }
      } else {
        return ApiResponse<Map<String, dynamic>>(
          error: response.body,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        error: 'Failed to upload image: $e',
        statusCode: 0,
      );
    }
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

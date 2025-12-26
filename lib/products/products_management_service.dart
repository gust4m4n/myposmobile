import '../shared/api_models.dart';
import '../shared/utils/api_x.dart';

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
      '/products',
      body: {
        'name': name,
        'description': description,
        'category': category,
        'sku': sku,
        'price': price,
        'stock': stock,
        'is_active': isActive,
      },
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
      '/products/$id',
      body: {
        'name': name,
        'description': description,
        'category': category,
        'sku': sku,
        'price': price,
        'stock': stock,
        'is_active': isActive,
      },
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> deleteProduct({
    required int id,
  }) async {
    return await ApiX.delete('/products/$id');
  }
}

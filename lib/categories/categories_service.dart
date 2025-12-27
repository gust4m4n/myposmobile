import '../shared/api_models.dart';
import '../shared/utils/api_x.dart';

class CategoriesService {
  /// Get all categories for tenant
  static Future<ApiResponse<List<dynamic>>> getCategories({
    bool activeOnly = false,
  }) async {
    final queryParams = activeOnly ? '?active_only=true' : '';
    return await ApiX.get('/categories$queryParams');
  }

  /// Get category by ID
  static Future<ApiResponse<Map<String, dynamic>>> getCategoryById(
    int id,
  ) async {
    return await ApiX.get('/categories/$id');
  }

  /// Create new category
  static Future<ApiResponse<Map<String, dynamic>>> createCategory({
    required String name,
    required String description,
    required bool isActive,
  }) async {
    return await ApiX.post(
      '/categories',
      body: {'name': name, 'description': description, 'is_active': isActive},
    );
  }

  /// Update existing category
  static Future<ApiResponse<Map<String, dynamic>>> updateCategory({
    required int id,
    required String name,
    required String description,
    required bool isActive,
  }) async {
    return await ApiX.put(
      '/categories/$id',
      body: {'name': name, 'description': description, 'is_active': isActive},
    );
  }

  /// Delete category (soft delete)
  static Future<ApiResponse<Map<String, dynamic>>> deleteCategory(
    int id,
  ) async {
    return await ApiX.delete('/categories/$id');
  }
}

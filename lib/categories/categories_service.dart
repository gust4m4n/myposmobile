import '../shared/api_models.dart';
import '../shared/utils/api_x.dart';

class CategoriesService {
  /// Get all categories for tenant with optional pagination
  static Future<ApiResponse<List<dynamic>>> getCategories({
    bool activeOnly = false,
    int? page,
    int? pageSize,
  }) async {
    final queryParams = <String>[];
    if (activeOnly) queryParams.add('active_only=true');
    if (page != null) queryParams.add('page=$page');
    if (pageSize != null) queryParams.add('page_size=$pageSize');

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.join('&')}'
        : '';
    return await ApiX.get('/api/v1/categories$queryString', requiresAuth: true);
  }

  /// Get category by ID
  static Future<ApiResponse<Map<String, dynamic>>> getCategoryById(
    int id,
  ) async {
    return await ApiX.get('/api/v1/categories/$id', requiresAuth: true);
  }

  /// Create new category
  static Future<ApiResponse<Map<String, dynamic>>> createCategory({
    required String name,
    required String description,
    required bool isActive,
  }) async {
    return await ApiX.post(
      '/api/v1/categories',
      requiresAuth: true,
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
      '/api/v1/categories/$id',
      requiresAuth: true,
      body: {'name': name, 'description': description, 'is_active': isActive},
    );
  }

  /// Delete category (soft delete)
  static Future<ApiResponse<Map<String, dynamic>>> deleteCategory(
    int id,
  ) async {
    return await ApiX.delete('/api/v1/categories/$id', requiresAuth: true);
  }
}

import '../../shared/api_models.dart';
import '../../shared/config/api_config.dart';
import '../../shared/utils/api_x.dart';
import '../models/category_model.dart';

class CategoriesManagementService {
  /// Get list of all categories with optional pagination
  Future<ApiResponse<PaginatedResponse<CategoryModel>>> getCategories({
    int? page,
    int? pageSize,
    bool? activeOnly,
  }) async {
    String url = ApiConfig.categories;
    final queryParams = <String>[];

    if (page != null) queryParams.add('page=$page');
    if (pageSize != null) queryParams.add('page_size=$pageSize');
    if (activeOnly != null) queryParams.add('active_only=$activeOnly');

    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    // Get raw response without fromJson transformation
    final response = await ApiX.get<dynamic>(url, requiresAuth: true);

    // Manually transform response to PaginatedResponse
    if (response.data != null && response.data is Map) {
      final jsonData = response.data as Map<String, dynamic>;
      final paginatedData = PaginatedResponse<CategoryModel>(
        page: jsonData['page'] ?? 1,
        pageSize: jsonData['page_size'] ?? 20,
        totalItems: jsonData['total_items'] ?? 0,
        totalPages: jsonData['total_pages'] ?? 1,
        data:
            (jsonData['data'] as List<dynamic>?)
                ?.map(
                  (item) =>
                      CategoryModel.fromJson(item as Map<String, dynamic>),
                )
                .toList() ??
            [],
      );

      return ApiResponse<PaginatedResponse<CategoryModel>>(
        code: response.code,
        message: response.message,
        data: paginatedData,
        error: response.error,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse<PaginatedResponse<CategoryModel>>(
      code: response.code,
      message: response.message,
      data: null,
      error: response.error,
      statusCode: response.statusCode,
    );
  }

  /// Get single category by ID
  Future<ApiResponse<CategoryModel>> getCategory(int id) async {
    return await ApiX.get(
      '${ApiConfig.categories}/$id',
      requiresAuth: true,
      fromJson: (data) => CategoryModel.fromJson(data),
    );
  }

  /// Create new category with optional image upload
  /// Uses multipart/form-data when image is provided, JSON otherwise
  Future<ApiResponse<CategoryModel>> createCategory({
    required String name,
    required String description,
    required bool isActive,
    String? imagePath,
  }) async {
    if (imagePath != null) {
      // Use multipart/form-data for image upload
      return await ApiX.postMultipart<CategoryModel>(
        ApiConfig.categories,
        fields: {
          'name': name,
          'description': description,
          'is_active': isActive.toString(),
        },
        filePath: imagePath,
        fileFieldName: 'image',
        requiresAuth: true,
        fromJson: (data) => CategoryModel.fromJson(data),
      );
    } else {
      // Use JSON body when no image
      return await ApiX.post(
        ApiConfig.categories,
        body: {'name': name, 'description': description, 'is_active': isActive},
        requiresAuth: true,
        fromJson: (data) => CategoryModel.fromJson(data),
      );
    }
  }

  /// Update existing category with optional image upload
  /// Uses multipart/form-data when image is provided, JSON otherwise
  Future<ApiResponse<CategoryModel>> updateCategory({
    required int id,
    required String name,
    required String description,
    required bool isActive,
    String? imagePath,
  }) async {
    if (imagePath != null) {
      // Use multipart/form-data for image upload
      return await ApiX.putMultipart<CategoryModel>(
        '${ApiConfig.categories}/$id',
        fields: {
          'name': name,
          'description': description,
          'is_active': isActive.toString(),
        },
        filePath: imagePath,
        fileFieldName: 'image',
        requiresAuth: true,
        fromJson: (data) => CategoryModel.fromJson(data),
      );
    } else {
      // Use JSON body when no image (Postman also supports this)
      return await ApiX.put(
        '${ApiConfig.categories}/$id',
        body: {'name': name, 'description': description, 'is_active': isActive},
        requiresAuth: true,
        fromJson: (data) => CategoryModel.fromJson(data),
      );
    }
  }

  /// Delete category
  Future<ApiResponse<void>> deleteCategory(int id) async {
    return await ApiX.delete('${ApiConfig.categories}/$id', requiresAuth: true);
  }
}

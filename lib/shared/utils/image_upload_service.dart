import '../api_models.dart';
import 'api_x.dart';

class ImageUploadService {
  /// Upload profile photo
  /// POST /api/v1/profile/photo
  /// Returns the image URL on success
  static Future<ApiResponse<Map<String, dynamic>>> uploadProfilePhoto({
    required String filePath,
  }) async {
    return await ApiX.uploadFile(
      '/api/v1/profile/photo',
      filePath: filePath,
      fieldName: 'image',
    );
  }

  /// Delete profile photo
  /// DELETE /api/v1/profile/photo
  static Future<ApiResponse<Map<String, dynamic>>> deleteProfilePhoto() async {
    return await ApiX.delete('/api/v1/profile/photo');
  }

  /// Upload product photo
  /// POST /api/v1/products/:id/photo
  static Future<ApiResponse<Map<String, dynamic>>> uploadProductPhoto({
    required int productId,
    required String filePath,
  }) async {
    return await ApiX.uploadFile(
      '/api/v1/products/$productId/photo',
      filePath: filePath,
      fieldName: 'image',
    );
  }

  /// Delete product photo
  /// DELETE /api/v1/products/:id/photo
  static Future<ApiResponse<Map<String, dynamic>>> deleteProductPhoto({
    required int productId,
  }) async {
    return await ApiX.delete('/api/v1/products/$productId/photo');
  }
}

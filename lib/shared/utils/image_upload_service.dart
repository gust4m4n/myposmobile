import '../shared/api_models.dart';
import '../shared/utils/api_x.dart';

class ImageUploadService {
  /// Upload profile photo
  /// Returns the image URL on success
  static Future<ApiResponse<Map<String, dynamic>>> uploadProfilePhoto({
    required String filePath,
  }) async {
    return await ApiX.uploadFile(
      '/profile/photo',
      filePath: filePath,
      fieldName: 'image',
    );
  }

  /// Delete profile photo
  static Future<ApiResponse<Map<String, dynamic>>> deleteProfilePhoto() async {
    return await ApiX.delete('/profile/photo');
  }

  /// Upload product photo
  static Future<ApiResponse<Map<String, dynamic>>> uploadProductPhoto({
    required int productId,
    required String filePath,
  }) async {
    return await ApiX.uploadFile(
      '/products/$productId/photo',
      filePath: filePath,
      fieldName: 'image',
    );
  }

  /// Delete product photo
  static Future<ApiResponse<Map<String, dynamic>>> deleteProductPhoto({
    required int productId,
  }) async {
    return await ApiX.delete('/products/$productId/photo');
  }
}

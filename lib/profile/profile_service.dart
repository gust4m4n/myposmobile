import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../shared/api_models.dart';
import '../shared/config/api_config.dart';
import '../shared/utils/api_x.dart';
import '../shared/utils/storage_service.dart';

class ProfileService {
  /// GET /api/v1/profile
  /// Get current user profile
  /// Requires JWT token in Authorization header
  ///
  /// Returns: ProfileModel with user profile information
  Future<ApiResponse<ProfileModel>> getProfile() async {
    return ApiX.get<ProfileModel>(
      ApiConfig.profile,
      requiresAuth: true,
      fromJson: (data) {
        return ProfileModel.fromJson(data);
      },
    );
  }

  /// PUT /api/v1/profile
  /// Update current user profile
  /// Requires JWT token in Authorization header
  ///
  /// Parameters (all optional):
  /// - email: User's email address
  /// - fullName: User's full name
  /// - pin: 6-digit PIN (optional)
  ///
  /// Returns: Updated ProfileModel
  Future<ApiResponse<ProfileModel>> updateProfile({
    String? email,
    String? fullName,
    String? pin,
  }) async {
    final body = <String, dynamic>{};
    if (email != null) body['email'] = email;
    if (fullName != null) body['full_name'] = fullName;
    if (pin != null) body['pin'] = pin;

    return ApiX.put<ProfileModel>(
      ApiConfig.profile,
      requiresAuth: true,
      body: body,
      fromJson: (data) {
        return ProfileModel.fromJson(data);
      },
    );
  }

  /// POST /api/v1/profile/photo
  /// Upload profile photo
  /// Requires JWT token in Authorization header
  ///
  /// Parameters:
  /// - imageFile: Image file to upload (jpg, jpeg, png, gif, webp, max 5MB)
  ///
  /// Returns: Updated ProfileModel with new photo URL
  Future<ApiResponse<ProfileModel>> uploadProfileImage({
    required File imageFile,
  }) async {
    try {
      final storage = await StorageService.getInstance();
      final token = storage.getToken();

      if (token == null) {
        return ApiResponse<ProfileModel>(
          error: 'No authentication token',
          statusCode: 401,
        );
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.profile}/photo');
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
        final data = json.decode(response.body) as Map<String, dynamic>;
        return ApiResponse<ProfileModel>(
          data: ProfileModel.fromJson(data),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<ProfileModel>(
          error: response.body,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<ProfileModel>(
        error: 'Failed to upload profile image: $e',
        statusCode: 0,
      );
    }
  }

  /// DELETE /api/v1/profile/photo
  /// Delete profile photo
  /// Requires JWT token in Authorization header
  ///
  /// Returns: Updated ProfileModel without photo
  Future<ApiResponse<ProfileModel>> deleteProfileImage() async {
    return ApiX.delete<ProfileModel>(
      '${ApiConfig.profile}/photo',
      requiresAuth: true,
      fromJson: (data) {
        return ProfileModel.fromJson(data);
      },
    );
  }
}

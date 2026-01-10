import 'dart:io';

import '../../shared/api_models.dart';
import '../../shared/utils/api_x.dart';

class ProfileService {
  /// GET /api/v1/profile
  /// Get current user profile
  /// Requires JWT token in Authorization header
  ///
  /// Returns: ProfileModel with user profile information
  Future<ApiResponse<ProfileModel>> getProfile() async {
    return ApiX.get<ProfileModel>(
      '/profile',
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
      '/profile',
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
    return await ApiX.postMultipart<ProfileModel>(
      '/profile/photo',
      fields: {},
      filePath: imageFile.path,
      fileFieldName: 'image',
      requiresAuth: true,
      fromJson: (data) => ProfileModel.fromJson(data),
    );
  }

  /// DELETE /api/v1/profile/photo
  /// Delete profile photo
  /// Requires JWT token in Authorization header
  ///
  /// Returns: Updated ProfileModel without photo
  Future<ApiResponse<ProfileModel>> deleteProfileImage() async {
    return ApiX.delete<ProfileModel>(
      '/profile/photo',
      requiresAuth: true,
      fromJson: (data) {
        return ProfileModel.fromJson(data);
      },
    );
  }
}

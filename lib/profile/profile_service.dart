import '../shared/api_models.dart';
import '../shared/config/api_config.dart';
import '../shared/utils/api_x.dart';

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
}

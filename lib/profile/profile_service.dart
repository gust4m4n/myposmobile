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
      fromJson: (data) => ProfileModel.fromJson(data),
    );
  }
}

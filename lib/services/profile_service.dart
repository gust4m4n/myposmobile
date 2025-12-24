import 'dart:convert';

import '../config/api_config.dart';
import '../models/api_models.dart';
import '../utils/http_client.dart';

class ProfileService {
  final HttpClient _httpClient = HttpClient();

  /// GET /api/v1/profile
  /// Get current user profile
  /// Requires JWT token in Authorization header
  ///
  /// Returns: ProfileModel with user profile information
  Future<ApiResponse<ProfileModel>> getProfile() async {
    try {
      final response = await _httpClient.get(
        ApiConfig.profile,
        requiresAuth: true,
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse(data: ProfileModel.fromJson(jsonResponse));
      } else {
        return ApiResponse(
          error: jsonResponse['error'] ?? 'Failed to get profile',
        );
      }
    } catch (e) {
      return ApiResponse(error: 'Error getting profile: $e');
    }
  }
}

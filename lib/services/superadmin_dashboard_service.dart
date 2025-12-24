import 'dart:convert';

import '../config/api_config.dart';
import '../models/api_models.dart';
import '../utils/http_client.dart';

class SuperadminDashboardService {
  final HttpClient _httpClient = HttpClient();

  /// GET /api/v1/superadmin/dashboard
  /// Get superadmin dashboard statistics
  /// Requires JWT token with superadmin role
  ///
  /// Returns: DashboardModel with total tenants, branches, and users
  Future<ApiResponse<DashboardModel>> getDashboard() async {
    try {
      final response = await _httpClient.get(
        ApiConfig.superadminDashboard,
        requiresAuth: true,
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(
          jsonResponse,
          (data) => DashboardModel.fromJson(data),
        );
      } else {
        return ApiResponse(
          error: jsonResponse['error'] ?? 'Failed to get dashboard',
        );
      }
    } catch (e) {
      return ApiResponse(error: 'Error getting dashboard: $e');
    }
  }
}

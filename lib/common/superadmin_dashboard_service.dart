import '../shared/api_models.dart';
import '../shared/config/api_config.dart';
import '../shared/utils/api_x.dart';

class SuperadminDashboardService {
  /// GET /api/v1/superadmin/dashboard
  /// Get superadmin dashboard statistics
  /// Requires JWT token with superadmin role
  ///
  /// Returns: DashboardModel with total tenants, branches, and users
  Future<ApiResponse<DashboardModel>> getDashboard() async {
    return await ApiX.get(
      ApiConfig.superadminDashboard,
      requiresAuth: true,
      fromJson: (json) => DashboardModel.fromJson(json),
    );
  }
}

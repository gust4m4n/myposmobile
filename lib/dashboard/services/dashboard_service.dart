import '../../shared/api_models.dart' hide DashboardModel;
import '../../shared/config/api_config.dart';
import '../../shared/utils/api_x.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  /// GET /api/v1/superadmin/dashboard
  /// Get comprehensive dashboard statistics
  /// Requires JWT token with superadmin role
  ///
  /// Returns: DashboardModel with all statistics
  Future<ApiResponse<DashboardModel>> getDashboard() async {
    return await ApiX.get(
      ApiConfig.superadminDashboard,
      requiresAuth: true,
      fromJson: (data) => DashboardModel.fromJson(data),
    );
  }
}

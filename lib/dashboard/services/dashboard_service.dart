import '../../shared/api_models.dart' hide DashboardModel;
import '../../shared/utils/api_x.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  /// GET /api/v1/dashboard
  /// Get comprehensive dashboard statistics
  /// Requires JWT token
  ///
  /// Returns: DashboardModel with all statistics
  Future<ApiResponse<DashboardModel>> getDashboard() async {
    return await ApiX.get(
      '/dashboard',
      requiresAuth: true,
      fromJson: (data) => DashboardModel.fromJson(data),
    );
  }
}

import 'api_models.dart';
import 'config/api_config.dart';
import 'utils/api_x.dart';

class HealthCheckService {
  /// GET /health
  /// Check server health status
  static Future<ApiResponse<Map<String, dynamic>>> checkHealth() async {
    return await ApiX.get<Map<String, dynamic>>(
      ApiConfig.health,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
}

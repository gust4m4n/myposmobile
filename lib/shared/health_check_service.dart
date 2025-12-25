import 'dart:convert';

import 'config/api_config.dart';
import 'utils/http_client.dart';

class HealthCheckService {
  final HttpClient _httpClient = HttpClient();

  /// GET /health
  /// Check server health status
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await _httpClient.get(ApiConfig.health);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to check health: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking health: $e');
    }
  }
}

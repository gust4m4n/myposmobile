import 'dart:convert';

import '../shared/api_models.dart';
import '../shared/config/api_config.dart';
import '../shared/utils/http_client.dart';

/// Service untuk mendapatkan daftar semua tenant aktif (dev endpoint).
/// Endpoint public yang tidak memerlukan authentication token.
/// Gunakan untuk testing, mendapatkan tenant_id, atau development.
class DevTenantsService {
  /// Get list of all active tenants
  ///
  /// Public endpoint - tidak memerlukan authentication
  ///
  /// Returns:
  /// - List<Map<String, dynamic>> berisi data tenants
  /// - Contoh: [{id: 17, name: "Warung Makan Sejahtera", code: "resto01", ...}]
  static Future<ApiResponse<List<Map<String, dynamic>>>> getDevTenants() async {
    try {
      final response = await HttpClient().get(
        ApiConfig.devTenants,
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tenants = (data['data'] as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();

        return ApiResponse<List<Map<String, dynamic>>>(
          data: tenants,
          message: data['message'] ?? 'Tenants retrieved successfully',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse<List<Map<String, dynamic>>>(
          error: errorData['error'] ?? 'Failed to get tenants',
        );
      }
    } catch (e) {
      return ApiResponse<List<Map<String, dynamic>>>(
        error: 'Error getting tenants: $e',
      );
    }
  }
}

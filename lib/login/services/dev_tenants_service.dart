import '../../shared/api_models.dart';
import '../../shared/utils/api_x.dart';

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
    return ApiX.get<List<Map<String, dynamic>>>(
      '/dev/tenants',
      requiresAuth: false,
      fromJson: (data) =>
          (data as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }
}

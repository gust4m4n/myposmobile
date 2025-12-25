import 'dart:convert';

import '../shared/api_models.dart';
import '../shared/config/api_config.dart';
import '../shared/utils/http_client.dart';

/// Service untuk mendapatkan daftar branches dari tenant tertentu (dev endpoint).
/// Endpoint public yang tidak memerlukan authentication token.
/// Gunakan untuk testing, mendapatkan branch_id, atau development.
class DevBranchesService {
  /// Get list of branches by tenant ID
  ///
  /// Public endpoint - tidak memerlukan authentication
  ///
  /// Parameters:
  /// - tenantId: ID tenant yang ingin dilihat branches-nya
  ///
  /// Returns:
  /// - List<Map<String, dynamic>> berisi data branches
  /// - Contoh: [{ID: 25, name: "Cabang Pusat", code: "resto01-pusat", ...}]
  ///
  /// Example:
  /// ```dart
  /// // Get branches untuk Warung Makan Sejahtera (tenant_id=17)
  /// final result = await DevBranchesService.getDevBranches(17);
  /// ```
  static Future<ApiResponse<List<Map<String, dynamic>>>> getDevBranches(
    int tenantId,
  ) async {
    try {
      final response = await HttpClient().get(
        ApiConfig.devTenantBranches(tenantId),
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final branches = (data['data'] as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();

        return ApiResponse<List<Map<String, dynamic>>>(
          data: branches,
          message: data['message'] ?? 'Branches retrieved successfully',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse<List<Map<String, dynamic>>>(
          error: errorData['error'] ?? 'Failed to get branches',
        );
      }
    } catch (e) {
      return ApiResponse<List<Map<String, dynamic>>>(
        error: 'Error getting branches: $e',
      );
    }
  }
}

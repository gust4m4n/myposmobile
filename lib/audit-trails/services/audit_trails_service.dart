import '../../shared/api_models.dart';
import '../../shared/utils/api_x.dart';

class AuditTrailsService {
  /// Get paginated list of audit trails with filters
  static Future<ApiResponse<Map<String, dynamic>>> getAuditTrails({
    int page = 1,
    int limit = 20,
    int? userId,
    String? entityType,
    int? entityId,
    String? action,
    String? dateFrom,
    String? dateTo,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (userId != null) queryParams['user_id'] = userId.toString();
    if (entityType != null && entityType.isNotEmpty) {
      queryParams['entity_type'] = entityType;
    }
    if (entityId != null) queryParams['entity_id'] = entityId.toString();
    if (action != null && action.isNotEmpty) queryParams['action'] = action;
    if (dateFrom != null && dateFrom.isNotEmpty) {
      queryParams['date_from'] = dateFrom;
    }
    if (dateTo != null && dateTo.isNotEmpty) {
      queryParams['date_to'] = dateTo;
    }

    final uri = Uri(path: '/api/v1/audit-trails', queryParameters: queryParams);

    return await ApiX.get(uri.toString(), requiresAuth: true);
  }

  /// Get specific audit trail by ID
  static Future<ApiResponse<Map<String, dynamic>>> getAuditTrailById(
    int id,
  ) async {
    return await ApiX.get('/api/v1/audit-trails/$id', requiresAuth: true);
  }

  /// Get audit history for specific entity
  static Future<ApiResponse<Map<String, dynamic>>> getEntityAuditHistory({
    required String entityType,
    required int entityId,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final uri = Uri(
      path: '/api/v1/audit-trails/entity/$entityType/$entityId',
      queryParameters: queryParams,
    );

    return await ApiX.get(uri.toString(), requiresAuth: true);
  }

  /// Get activity log for specific user
  static Future<ApiResponse<Map<String, dynamic>>> getUserActivityLog({
    required int userId,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final uri = Uri(
      path: '/api/v1/audit-trails/user/$userId',
      queryParameters: queryParams,
    );

    return await ApiX.get(uri.toString(), requiresAuth: true);
  }
}

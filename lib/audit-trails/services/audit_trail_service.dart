import '../../shared/api_models.dart';
import '../../shared/config/api_config.dart';
import '../../shared/utils/api_x.dart';
import '../models/audit_trail_model.dart';

class AuditTrailService {
  /// List audit trails with optional filters
  ///
  /// Parameters:
  /// - page: Page number (default: 1)
  /// - limit: Items per page (default: 32)
  /// - userId: Filter by user ID (optional)
  /// - entityType: Filter by entity type (user, product, order, payment, category, faq, tnc) (optional)
  /// - entityId: Filter by entity ID (optional)
  /// - action: Filter by action (create, update, delete, login, logout) (optional)
  /// - dateFrom: Filter from date YYYY-MM-DD (optional)
  /// - dateTo: Filter to date YYYY-MM-DD (optional)
  ///
  /// Returns:
  /// - AuditTrailListResponse with pagination metadata
  ///
  /// Example:
  /// ```dart
  /// final result = await AuditTrailService.listAuditTrails(
  ///   page: 1,
  ///   limit: 20,
  ///   entityType: 'product',
  ///   action: 'update',
  /// );
  /// ```
  static Future<ApiResponse<AuditTrailListResponse>> listAuditTrails({
    int page = 1,
    int limit = 32,
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
    if (entityType != null) queryParams['entity_type'] = entityType;
    if (entityId != null) queryParams['entity_id'] = entityId.toString();
    if (action != null) queryParams['action'] = action;
    if (dateFrom != null) queryParams['date_from'] = dateFrom;
    if (dateTo != null) queryParams['date_to'] = dateTo;

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.auditTrails}',
    ).replace(queryParameters: queryParams);

    return ApiX.get<AuditTrailListResponse>(
      uri.toString().replaceFirst(ApiConfig.baseUrl, ''),
      requiresAuth: true,
      fromJson: (data) =>
          AuditTrailListResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Get audit trail by ID
  ///
  /// Parameters:
  /// - id: Audit trail ID
  ///
  /// Returns:
  /// - AuditTrailModel detail
  ///
  /// Example:
  /// ```dart
  /// final result = await AuditTrailService.getAuditTrailById(43);
  /// ```
  static Future<ApiResponse<AuditTrailModel>> getAuditTrailById(int id) async {
    return ApiX.get<AuditTrailModel>(
      '${ApiConfig.auditTrails}/$id',
      requiresAuth: true,
      fromJson: (data) =>
          AuditTrailModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Get entity audit history
  ///
  /// Get complete audit history for a specific entity.
  /// Shows all changes made to this entity over time.
  ///
  /// Parameters:
  /// - entityType: Entity type (user, product, order, payment, category, faq, tnc)
  /// - entityId: Entity ID
  /// - page: Page number (default: 1)
  /// - limit: Items per page (default: 20)
  ///
  /// Returns:
  /// - AuditTrailListResponse with entity history
  ///
  /// Example:
  /// ```dart
  /// final result = await AuditTrailService.getEntityHistory(
  ///   entityType: 'product',
  ///   entityId: 234,
  ///   page: 1,
  ///   limit: 20,
  /// );
  /// ```
  static Future<ApiResponse<AuditTrailListResponse>> getEntityHistory({
    required String entityType,
    required int entityId,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.auditTrails}/entity/$entityType/$entityId',
    ).replace(queryParameters: queryParams);

    return ApiX.get<AuditTrailListResponse>(
      uri.toString().replaceFirst(ApiConfig.baseUrl, ''),
      requiresAuth: true,
      fromJson: (data) =>
          AuditTrailListResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Get user activity log
  ///
  /// Get complete activity log for a specific user.
  /// Shows all actions performed by this user across all entities.
  ///
  /// Parameters:
  /// - userId: User ID
  /// - page: Page number (default: 1)
  /// - limit: Items per page (default: 20)
  ///
  /// Returns:
  /// - AuditTrailListResponse with user activities
  ///
  /// Example:
  /// ```dart
  /// final result = await AuditTrailService.getUserActivity(
  ///   userId: 60,
  ///   page: 1,
  ///   limit: 20,
  /// );
  /// ```
  static Future<ApiResponse<AuditTrailListResponse>> getUserActivity({
    required int userId,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.auditTrails}/user/$userId',
    ).replace(queryParameters: queryParams);

    return ApiX.get<AuditTrailListResponse>(
      uri.toString().replaceFirst(ApiConfig.baseUrl, ''),
      requiresAuth: true,
      fromJson: (data) =>
          AuditTrailListResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Get recent audit trails (convenience method)
  ///
  /// Returns:
  /// - Recent 20 audit trails
  ///
  /// Example:
  /// ```dart
  /// final result = await AuditTrailService.getRecentAudits();
  /// ```
  static Future<ApiResponse<AuditTrailListResponse>> getRecentAudits() async {
    return listAuditTrails(page: 1, limit: 20);
  }

  /// Search audit trails by entity type
  ///
  /// Parameters:
  /// - entityType: Entity type to filter (user, product, order, payment, category, faq, tnc)
  /// - page: Page number (default: 1)
  /// - limit: Items per page (default: 32)
  ///
  /// Returns:
  /// - AuditTrailListResponse filtered by entity type
  ///
  /// Example:
  /// ```dart
  /// final result = await AuditTrailService.searchByEntityType('product');
  /// ```
  static Future<ApiResponse<AuditTrailListResponse>> searchByEntityType(
    String entityType, {
    int page = 1,
    int limit = 32,
  }) async {
    return listAuditTrails(page: page, limit: limit, entityType: entityType);
  }

  /// Search audit trails by action
  ///
  /// Parameters:
  /// - action: Action to filter (create, update, delete, login, logout)
  /// - page: Page number (default: 1)
  /// - limit: Items per page (default: 32)
  ///
  /// Returns:
  /// - AuditTrailListResponse filtered by action
  ///
  /// Example:
  /// ```dart
  /// final result = await AuditTrailService.searchByAction('create');
  /// ```
  static Future<ApiResponse<AuditTrailListResponse>> searchByAction(
    String action, {
    int page = 1,
    int limit = 32,
  }) async {
    return listAuditTrails(page: page, limit: limit, action: action);
  }

  /// Get audit trails for date range
  ///
  /// Parameters:
  /// - dateFrom: Start date (YYYY-MM-DD)
  /// - dateTo: End date (YYYY-MM-DD)
  /// - page: Page number (default: 1)
  /// - limit: Items per page (default: 32)
  ///
  /// Returns:
  /// - AuditTrailListResponse within date range
  ///
  /// Example:
  /// ```dart
  /// final result = await AuditTrailService.getAuditsByDateRange(
  ///   dateFrom: '2026-01-01',
  ///   dateTo: '2026-01-09',
  /// );
  /// ```
  static Future<ApiResponse<AuditTrailListResponse>> getAuditsByDateRange({
    required String dateFrom,
    required String dateTo,
    int page = 1,
    int limit = 32,
  }) async {
    return listAuditTrails(
      page: page,
      limit: limit,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }
}

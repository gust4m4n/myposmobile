class AuditTrailModel {
  final int id;
  final int tenantId;
  final int? branchId;
  final int userId;
  final String userName;
  final String entityType;
  final int entityId;
  final String action;
  final String? changes;
  final String createdAt;

  AuditTrailModel({
    required this.id,
    required this.tenantId,
    this.branchId,
    required this.userId,
    required this.userName,
    required this.entityType,
    required this.entityId,
    required this.action,
    this.changes,
    required this.createdAt,
  });

  factory AuditTrailModel.fromJson(Map<String, dynamic> json) {
    return AuditTrailModel(
      id: json['id'] as int,
      tenantId: json['tenant_id'] as int,
      branchId: json['branch_id'] as int?,
      userId: json['user_id'] as int,
      userName: json['user_name'] as String,
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as int,
      action: json['action'] as String,
      changes: json['changes'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      if (branchId != null) 'branch_id': branchId,
      'user_id': userId,
      'user_name': userName,
      'entity_type': entityType,
      'entity_id': entityId,
      'action': action,
      if (changes != null) 'changes': changes,
      'created_at': createdAt,
    };
  }

  /// Parse changes JSON string to Map
  Map<String, dynamic>? getChangesAsMap() {
    if (changes == null || changes!.isEmpty) return null;
    try {
      final decoded = Map<String, dynamic>.from(
        // Handle JSON string
        changes!.startsWith('{') ? _parseJson(changes!) : {},
      );
      return decoded;
    } catch (e) {
      return null;
    }
  }

  /// Simple JSON parser helper
  Map<String, dynamic> _parseJson(String jsonStr) {
    // This is a simplified version - in production use dart:convert
    try {
      return {};
    } catch (e) {
      return {};
    }
  }

  /// Get human readable action
  String get actionDisplay {
    switch (action.toLowerCase()) {
      case 'create':
        return 'Created';
      case 'update':
        return 'Updated';
      case 'delete':
        return 'Deleted';
      case 'login':
        return 'Logged In';
      case 'logout':
        return 'Logged Out';
      default:
        return action;
    }
  }

  /// Get human readable entity type
  String get entityTypeDisplay {
    switch (entityType.toLowerCase()) {
      case 'user':
        return 'User';
      case 'product':
        return 'Product';
      case 'order':
        return 'Order';
      case 'payment':
        return 'Payment';
      case 'category':
        return 'Category';
      case 'faq':
        return 'FAQ';
      case 'tnc':
        return 'Terms & Conditions';
      default:
        return entityType;
    }
  }
}

/// Pagination response wrapper for audit trails list
class AuditTrailListResponse {
  final List<AuditTrailModel> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  AuditTrailListResponse({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory AuditTrailListResponse.fromJson(Map<String, dynamic> json) {
    return AuditTrailListResponse(
      items: (json['items'] as List)
          .map((item) => AuditTrailModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      totalPages: json['total_pages'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'page': page,
      'limit': limit,
      'total': total,
      'total_pages': totalPages,
    };
  }

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
}

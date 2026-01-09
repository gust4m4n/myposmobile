class SyncUploadRequest {
  final String clientId;
  final String clientTimestamp;
  final List<Map<String, dynamic>>? users;
  final List<Map<String, dynamic>>? products;
  final List<Map<String, dynamic>>? categories;
  final List<Map<String, dynamic>>? orders;
  final List<Map<String, dynamic>>? payments;
  final List<Map<String, dynamic>>? auditTrails;
  final String? lastSyncAt;

  SyncUploadRequest({
    required this.clientId,
    required this.clientTimestamp,
    this.users,
    this.products,
    this.categories,
    this.orders,
    this.payments,
    this.auditTrails,
    this.lastSyncAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'client_id': clientId,
      'client_timestamp': clientTimestamp,
      if (users != null && users!.isNotEmpty) 'users': users,
      if (products != null && products!.isNotEmpty) 'products': products,
      if (categories != null && categories!.isNotEmpty)
        'categories': categories,
      if (orders != null && orders!.isNotEmpty) 'orders': orders,
      if (payments != null && payments!.isNotEmpty) 'payments': payments,
      if (auditTrails != null && auditTrails!.isNotEmpty)
        'audit_trails': auditTrails,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
    };
  }
}

class SyncUploadResponse {
  final int code;
  final String message;
  final SyncUploadData data;

  SyncUploadResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory SyncUploadResponse.fromJson(Map<String, dynamic> json) {
    return SyncUploadResponse(
      code: json['code'] as int,
      message: json['message'] as String,
      data: SyncUploadData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class SyncUploadData {
  final String syncId;
  final int processedUsers;
  final int processedProducts;
  final int processedCategories;
  final int processedOrders;
  final int processedPayments;
  final int processedAudits;
  final int processedTenants;
  final int processedBranches;
  final int failedUsers;
  final int failedProducts;
  final int failedCategories;
  final int failedOrders;
  final int failedPayments;
  final int failedAudits;
  final int failedTenants;
  final int failedBranches;
  final List<dynamic> conflicts;
  final Map<String, int> userMapping;
  final Map<String, int> productMapping;
  final Map<String, int> categoryMapping;
  final Map<String, int> orderMapping;
  final Map<String, int> paymentMapping;
  final Map<String, int> auditMapping;
  final String syncTimestamp;
  final List<String> errors;

  SyncUploadData({
    required this.syncId,
    required this.processedUsers,
    required this.processedProducts,
    required this.processedCategories,
    required this.processedOrders,
    required this.processedPayments,
    required this.processedAudits,
    required this.processedTenants,
    required this.processedBranches,
    required this.failedUsers,
    required this.failedProducts,
    required this.failedCategories,
    required this.failedOrders,
    required this.failedPayments,
    required this.failedAudits,
    required this.failedTenants,
    required this.failedBranches,
    required this.conflicts,
    required this.userMapping,
    required this.productMapping,
    required this.categoryMapping,
    required this.orderMapping,
    required this.paymentMapping,
    required this.auditMapping,
    required this.syncTimestamp,
    required this.errors,
  });

  factory SyncUploadData.fromJson(Map<String, dynamic> json) {
    return SyncUploadData(
      syncId: json['sync_id'] as String,
      processedUsers: json['processed_users'] as int? ?? 0,
      processedProducts: json['processed_products'] as int? ?? 0,
      processedCategories: json['processed_categories'] as int? ?? 0,
      processedOrders: json['processed_orders'] as int? ?? 0,
      processedPayments: json['processed_payments'] as int? ?? 0,
      processedAudits: json['processed_audits'] as int? ?? 0,
      processedTenants: json['processed_tenants'] as int? ?? 0,
      processedBranches: json['processed_branches'] as int? ?? 0,
      failedUsers: json['failed_users'] as int? ?? 0,
      failedProducts: json['failed_products'] as int? ?? 0,
      failedCategories: json['failed_categories'] as int? ?? 0,
      failedOrders: json['failed_orders'] as int? ?? 0,
      failedPayments: json['failed_payments'] as int? ?? 0,
      failedAudits: json['failed_audits'] as int? ?? 0,
      failedTenants: json['failed_tenants'] as int? ?? 0,
      failedBranches: json['failed_branches'] as int? ?? 0,
      conflicts: json['conflicts'] as List<dynamic>? ?? [],
      userMapping: Map<String, int>.from(json['user_mapping'] as Map? ?? {}),
      productMapping: Map<String, int>.from(
        json['product_mapping'] as Map? ?? {},
      ),
      categoryMapping: Map<String, int>.from(
        json['category_mapping'] as Map? ?? {},
      ),
      orderMapping: Map<String, int>.from(json['order_mapping'] as Map? ?? {}),
      paymentMapping: Map<String, int>.from(
        json['payment_mapping'] as Map? ?? {},
      ),
      auditMapping: Map<String, int>.from(json['audit_mapping'] as Map? ?? {}),
      syncTimestamp: json['sync_timestamp'] as String,
      errors: List<String>.from(json['errors'] as List? ?? []),
    );
  }

  bool get hasErrors =>
      failedUsers > 0 ||
      failedProducts > 0 ||
      failedCategories > 0 ||
      failedOrders > 0 ||
      failedPayments > 0 ||
      failedAudits > 0 ||
      errors.isNotEmpty;

  bool get hasConflicts => conflicts.isNotEmpty;

  int get totalProcessed =>
      processedUsers +
      processedProducts +
      processedCategories +
      processedOrders +
      processedPayments +
      processedAudits;

  int get totalFailed =>
      failedUsers +
      failedProducts +
      failedCategories +
      failedOrders +
      failedPayments +
      failedAudits;
}

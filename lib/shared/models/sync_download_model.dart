class SyncDownloadRequest {
  final String clientId;
  final String? lastSyncAt;
  final List<String>? entityTypes;

  SyncDownloadRequest({
    required this.clientId,
    this.lastSyncAt,
    this.entityTypes,
  });

  Map<String, dynamic> toJson() {
    return {
      'client_id': clientId,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (entityTypes != null && entityTypes!.isNotEmpty)
        'entity_types': entityTypes,
    };
  }
}

class SyncDownloadResponse {
  final int code;
  final String message;
  final SyncDownloadData data;

  SyncDownloadResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory SyncDownloadResponse.fromJson(Map<String, dynamic> json) {
    return SyncDownloadResponse(
      code: json['code'] as int,
      message: json['message'] as String,
      data: SyncDownloadData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class SyncDownloadData {
  final List<dynamic>? tenants;
  final List<dynamic>? branches;
  final List<dynamic>? users;
  final List<dynamic>? products;
  final List<dynamic>? categories;
  final String syncTimestamp;
  final bool hasMore;

  SyncDownloadData({
    this.tenants,
    this.branches,
    this.users,
    this.products,
    this.categories,
    required this.syncTimestamp,
    required this.hasMore,
  });

  factory SyncDownloadData.fromJson(Map<String, dynamic> json) {
    return SyncDownloadData(
      tenants: json['tenants'] as List<dynamic>?,
      branches: json['branches'] as List<dynamic>?,
      users: json['users'] as List<dynamic>?,
      products: json['products'] as List<dynamic>?,
      categories: json['categories'] as List<dynamic>?,
      syncTimestamp: json['sync_timestamp'] as String,
      hasMore: json['has_more'] as bool? ?? false,
    );
  }

  int get totalDownloaded =>
      (tenants?.length ?? 0) +
      (branches?.length ?? 0) +
      (users?.length ?? 0) +
      (products?.length ?? 0) +
      (categories?.length ?? 0);
}

class SyncStatusResponse {
  final int code;
  final String message;
  final SyncStatusData data;

  SyncStatusResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory SyncStatusResponse.fromJson(Map<String, dynamic> json) {
    return SyncStatusResponse(
      code: json['code'] as int,
      message: json['message'] as String,
      data: SyncStatusData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class SyncStatusData {
  final String clientId;
  final String? lastSyncAt;
  final int pendingUploads;
  final int pendingDownloads;
  final bool isSyncing;

  SyncStatusData({
    required this.clientId,
    this.lastSyncAt,
    required this.pendingUploads,
    required this.pendingDownloads,
    required this.isSyncing,
  });

  factory SyncStatusData.fromJson(Map<String, dynamic> json) {
    return SyncStatusData(
      clientId: json['client_id'] as String,
      lastSyncAt: json['last_sync_at'] as String?,
      pendingUploads: json['pending_uploads'] as int? ?? 0,
      pendingDownloads: json['pending_downloads'] as int? ?? 0,
      isSyncing: json['is_syncing'] as bool? ?? false,
    );
  }
}

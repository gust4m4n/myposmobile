import 'dart:io';

import '../../shared/api_models.dart' hide TenantModel;
import '../../shared/config/api_config.dart';
import '../../shared/utils/api_x.dart';
import '../models/tenant_model.dart';
import 'tenant_offline_service.dart';

class TenantsManagementService {
  final TenantOfflineService _offlineService = TenantOfflineService();

  /// Get list of all tenants with optional pagination
  Future<ApiResponse<PaginatedResponse<TenantModel>>> getTenants({
    int? page,
    int? pageSize,
  }) async {
    String url = ApiConfig.tenants;
    final queryParams = <String>[];

    if (page != null) queryParams.add('page=$page');
    if (pageSize != null) queryParams.add('page_size=$pageSize');

    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    // Get raw response without fromJson transformation
    final response = await ApiX.get<dynamic>(url, requiresAuth: true);

    // Manually transform response to PaginatedResponse
    if (response.data != null && response.data is Map) {
      final jsonData = response.data as Map<String, dynamic>;
      final paginatedData = PaginatedResponse<TenantModel>(
        page: jsonData['page'] ?? 1,
        pageSize: jsonData['page_size'] ?? 20,
        totalItems: jsonData['total_items'] ?? 0,
        totalPages: jsonData['total_pages'] ?? 1,
        data:
            (jsonData['data'] as List<dynamic>?)
                ?.map(
                  (item) => TenantModel.fromJson(item as Map<String, dynamic>),
                )
                .toList() ??
            [],
      );

      return ApiResponse<PaginatedResponse<TenantModel>>(
        code: response.code,
        message: response.message,
        data: paginatedData,
        error: response.error,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse<PaginatedResponse<TenantModel>>(
      code: response.code,
      message: response.message,
      data: null,
      error: response.error,
      statusCode: response.statusCode,
    );
  }

  /// Create new tenant
  Future<ApiResponse<TenantModel>> createTenant({
    required String name,
    required String description,
    required String address,
    required String website,
    required String email,
    required String phone,
    required bool isActive,
    File? imageFile,
  }) async {
    return await ApiX.postMultipart(
      ApiConfig.tenants,
      fields: {
        'name': name,
        'description': description,
        'address': address,
        'website': website,
        'email': email,
        'phone': phone,
        'is_active': isActive.toString(),
      },
      filePath: imageFile?.path,
      fileFieldName: 'image',
      requiresAuth: true,
      fromJson: (data) => TenantModel.fromJson(data),
    );
  }

  /// Update existing tenant
  Future<ApiResponse<TenantModel>> updateTenant({
    required int id,
    required String name,
    required String description,
    required String address,
    required String website,
    required String email,
    required String phone,
    required bool isActive,
    File? imageFile,
  }) async {
    return await ApiX.putMultipart(
      '${ApiConfig.tenants}/$id',
      fields: {
        'name': name,
        'description': description,
        'address': address,
        'website': website,
        'email': email,
        'phone': phone,
        'is_active': isActive.toString(),
      },
      filePath: imageFile?.path,
      fileFieldName: 'image',
      requiresAuth: true,
      fromJson: (data) => TenantModel.fromJson(data),
    );
  }

  /// Delete tenant
  Future<ApiResponse<void>> deleteTenant(int id) async {
    return await ApiX.delete('${ApiConfig.tenants}/$id', requiresAuth: true);
  }

  /// Sync tenants from server to local DB
  Future<void> syncTenantsFromServer() async {
    try {
      final response = await getTenants(page: 1, pageSize: 999999);
      if (response.statusCode == 200 && response.data != null) {
        final tenants = response.data!.data;
        await _offlineService.saveTenants(tenants);
      }
    } catch (e) {
      print('Error syncing tenants: $e');
      rethrow;
    }
  }

  /// Get tenants from local DB
  Future<List<TenantModel>> getTenantsFromLocal() async {
    return await _offlineService.getAllTenants();
  }

  /// Get active tenants from local DB
  Future<List<TenantModel>> getActiveTenantsFromLocal() async {
    return await _offlineService.getActiveTenants();
  }
}

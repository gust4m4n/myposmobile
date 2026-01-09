// Paginated Response Model
class PaginatedResponse<T> {
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;
  final List<T> data;

  PaginatedResponse({
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
    required this.data,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? 20,
      totalItems: json['total_items'] ?? 0,
      totalPages: json['total_pages'] ?? 1,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => fromJsonT(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'page': page,
      'page_size': pageSize,
      'total_items': totalItems,
      'total_pages': totalPages,
      'data': data.map((item) => toJsonT(item)).toList(),
    };
  }
}

// Base API Response
class ApiResponse<T> {
  final int? code;
  final String? message;
  final T? data;
  final String? error;
  final int statusCode;

  ApiResponse({
    this.code,
    this.message,
    this.data,
    this.error,
    required this.statusCode,
  });

  // Check if response is successful (2xx status code and no error)
  bool get isSuccess => statusCode >= 200 && statusCode < 300 && error == null;

  // Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      if (code != null) 'code': code,
      if (message != null) 'message': message,
      if (data != null) 'data': data,
      if (error != null) 'error': error,
      'statusCode': statusCode,
    };
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
    int statusCode,
  ) {
    // Handle different response formats:
    // 1. Standard format: {code: 0, message: "...", data: {...}}
    // 2. Old format: {message: "...", data: {...}, error: null}
    // 3. Direct format (no data wrapper): {user: {...}, tenant: {...}, ...}

    T? parsedData;

    if (fromJsonT != null) {
      if (json.containsKey('data') && json['data'] != null) {
        // Standard format with 'data' key
        parsedData = fromJsonT(json['data']);
      } else if (!json.containsKey('message') &&
          !json.containsKey('error') &&
          !json.containsKey('code')) {
        // Direct format - entire json is the data
        parsedData = fromJsonT(json);
      }
    } else {
      // No transformer provided, return entire json as T
      parsedData = json as T?;
    }

    return ApiResponse<T>(
      code: json['code'],
      message: json['message'],
      data: parsedData,
      error: json['error'],
      statusCode: statusCode,
    );
  }
}

// User Model (for login response)
class UserModel {
  final int id;
  final int tenantId;
  final int branchId;
  final String branchName;
  final String email;
  final String fullName;
  final String role;
  final bool isActive;

  UserModel({
    required this.id,
    required this.tenantId,
    required this.branchId,
    required this.branchName,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      tenantId: json['tenant_id'],
      branchId: json['branch_id'],
      branchName: json['branch_name'],
      email: json['email'],
      fullName: json['full_name'],
      role: json['role'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'branch_id': branchId,
      'branch_name': branchName,
      'email': email,
      'full_name': fullName,
      'role': role,
      'is_active': isActive,
    };
  }
}

// Auth Tenant Model
class AuthTenantModel {
  final int id;
  final String name;
  final String description;
  final String address;
  final String website;
  final String email;
  final String phone;
  final String image;
  final bool isActive;

  AuthTenantModel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.website,
    required this.email,
    required this.phone,
    required this.image,
    required this.isActive,
  });

  factory AuthTenantModel.fromJson(Map<String, dynamic> json) {
    return AuthTenantModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      website: json['website'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'] ?? '',
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'website': website,
      'email': email,
      'phone': phone,
      'image': image,
      'is_active': isActive,
    };
  }
}

// Auth Branch Model
class AuthBranchModel {
  final int id;
  final String name;
  final String description;
  final String address;
  final String website;
  final String email;
  final String phone;
  final String image;
  final bool isActive;

  AuthBranchModel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.website,
    required this.email,
    required this.phone,
    required this.image,
    required this.isActive,
  });

  factory AuthBranchModel.fromJson(Map<String, dynamic> json) {
    return AuthBranchModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      website: json['website'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'] ?? '',
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'website': website,
      'email': email,
      'phone': phone,
      'image': image,
      'is_active': isActive,
    };
  }
}

// Auth Response Data
class AuthResponseData {
  final String token;
  final UserModel user;
  final AuthTenantModel tenant;
  final AuthBranchModel branch;

  AuthResponseData({
    required this.token,
    required this.user,
    required this.tenant,
    required this.branch,
  });

  factory AuthResponseData.fromJson(Map<String, dynamic> json) {
    return AuthResponseData(
      token: json['token'],
      user: UserModel.fromJson(json['user']),
      tenant: AuthTenantModel.fromJson(json['tenant']),
      branch: AuthBranchModel.fromJson(json['branch']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
      'tenant': tenant.toJson(),
      'branch': branch.toJson(),
    };
  }
}

// Profile User Model
class ProfileUserModel {
  final int id;
  final String email;
  final String fullName;
  final String role;
  final bool isActive;
  final String? image;

  ProfileUserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isActive,
    this.image,
  });

  factory ProfileUserModel.fromJson(Map<String, dynamic> json) {
    return ProfileUserModel(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      role: json['role'],
      isActive: json['is_active'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'is_active': isActive,
      'image': image,
    };
  }
}

// Profile Tenant Model
class ProfileTenantModel {
  final int id;
  final String name;
  final bool isActive;

  ProfileTenantModel({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory ProfileTenantModel.fromJson(Map<String, dynamic> json) {
    return ProfileTenantModel(
      id: json['id'],
      name: json['name'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'is_active': isActive};
  }
}

// Profile Branch Model
class ProfileBranchModel {
  final int id;
  final String name;
  final String address;
  final String phone;
  final bool isActive;

  ProfileBranchModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.isActive,
  });

  factory ProfileBranchModel.fromJson(Map<String, dynamic> json) {
    return ProfileBranchModel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'is_active': isActive,
    };
  }
}

// Profile Model
class ProfileModel {
  final ProfileUserModel user;
  final ProfileTenantModel tenant;
  final ProfileBranchModel branch;

  ProfileModel({
    required this.user,
    required this.tenant,
    required this.branch,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      user: ProfileUserModel.fromJson(json['user']),
      tenant: ProfileTenantModel.fromJson(json['tenant']),
      branch: ProfileBranchModel.fromJson(json['branch']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'tenant': tenant.toJson(),
      'branch': branch.toJson(),
    };
  }
}

// Dashboard Model
class DashboardModel {
  final int totalTenants;
  final int totalBranches;
  final int totalUsers;

  DashboardModel({
    required this.totalTenants,
    required this.totalBranches,
    required this.totalUsers,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalTenants: json['total_tenants'],
      totalBranches: json['total_branches'],
      totalUsers: json['total_users'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_tenants': totalTenants,
      'total_branches': totalBranches,
      'total_users': totalUsers,
    };
  }
}

// Tenant Model
class TenantModel {
  final int id;
  final String name;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  TenantModel({
    required this.id,
    required this.name,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: json['id'],
      name: json['name'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// Branch Model
class BranchModel {
  final int id;
  final int tenantId;
  final String name;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  BranchModel({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'],
      tenantId: json['tenant_id'],
      name: json['name'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'name': name,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

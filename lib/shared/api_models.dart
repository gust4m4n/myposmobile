// Base API Response
class ApiResponse<T> {
  final String? message;
  final T? data;
  final String? error;
  final int statusCode;

  ApiResponse({this.message, this.data, this.error, required this.statusCode});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
    int statusCode,
  ) {
    // Handle different response formats:
    // 1. Standard format: {message: "...", data: {...}, error: null}
    // 2. Direct format (no data wrapper): {user: {...}, tenant: {...}, ...}

    T? parsedData;

    if (fromJsonT != null) {
      if (json.containsKey('data') && json['data'] != null) {
        // Standard format with 'data' key
        parsedData = fromJsonT(json['data']);
      } else if (!json.containsKey('message') && !json.containsKey('error')) {
        // Direct format - entire json is the data
        parsedData = fromJsonT(json);
      }
    } else {
      // No transformer provided, return entire json as T
      parsedData = json as T?;
    }

    return ApiResponse<T>(
      message: json['message'],
      data: parsedData,
      error: json['error'],
      statusCode: statusCode,
    );
  }
}

// User Model
class UserModel {
  final int id;
  final int tenantId;
  final int branchId;
  final String branchName;
  final String username;
  final String email;
  final String fullName;
  final bool isActive;

  UserModel({
    required this.id,
    required this.tenantId,
    required this.branchId,
    required this.branchName,
    required this.username,
    required this.email,
    required this.fullName,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      tenantId: json['tenant_id'],
      branchId: json['branch_id'],
      branchName: json['branch_name'],
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'branch_id': branchId,
      'branch_name': branchName,
      'username': username,
      'email': email,
      'full_name': fullName,
      'is_active': isActive,
    };
  }
}

// Auth Response Data
class AuthResponseData {
  final String token;
  final UserModel user;

  AuthResponseData({required this.token, required this.user});

  factory AuthResponseData.fromJson(Map<String, dynamic> json) {
    return AuthResponseData(
      token: json['token'],
      user: UserModel.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'user': user.toJson()};
  }
}

// Profile User Model
class ProfileUserModel {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String role;
  final bool isActive;
  final String? image;

  ProfileUserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isActive,
    this.image,
  });

  factory ProfileUserModel.fromJson(Map<String, dynamic> json) {
    return ProfileUserModel(
      id: json['id'],
      username: json['username'],
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
      'username': username,
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
  final String code;
  final bool isActive;

  ProfileTenantModel({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
  });

  factory ProfileTenantModel.fromJson(Map<String, dynamic> json) {
    return ProfileTenantModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'code': code, 'is_active': isActive};
  }
}

// Profile Branch Model
class ProfileBranchModel {
  final int id;
  final String name;
  final String code;
  final String address;
  final String phone;
  final bool isActive;

  ProfileBranchModel({
    required this.id,
    required this.name,
    required this.code,
    required this.address,
    required this.phone,
    required this.isActive,
  });

  factory ProfileBranchModel.fromJson(Map<String, dynamic> json) {
    return ProfileBranchModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      address: json['address'],
      phone: json['phone'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
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
  final String code;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  TenantModel({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
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
  final String code;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  BranchModel({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.code,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'],
      tenantId: json['tenant_id'],
      name: json['name'],
      code: json['code'],
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
      'code': code,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

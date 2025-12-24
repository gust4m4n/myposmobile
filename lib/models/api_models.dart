// Base API Response
class ApiResponse<T> {
  final String? message;
  final T? data;
  final String? error;

  ApiResponse({this.message, this.data, this.error});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      message: json['message'],
      data: fromJsonT != null && json['data'] != null
          ? fromJsonT(json['data'])
          : json['data'],
      error: json['error'],
    );
  }

  bool get isSuccess => error == null;
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

// Profile Model
class ProfileModel {
  final int userId;
  final int tenantId;
  final String username;

  ProfileModel({
    required this.userId,
    required this.tenantId,
    required this.username,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['user_id'],
      tenantId: json['tenant_id'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'tenant_id': tenantId, 'username': username};
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

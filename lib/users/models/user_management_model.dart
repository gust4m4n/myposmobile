class UserManagementModel {
  final int id;
  final int? remoteId;
  final int tenantId;
  final int branchId;
  final String? branchName;
  final String email;
  final String? password;
  final String? pin;
  final String fullName;
  final String? phone;
  final String role;
  final bool isActive;
  final String? image;
  final String? createdAt;
  final String? updatedAt;
  final int? createdBy;
  final String? createdByName;
  final int? updatedBy;
  final String? updatedByName;

  UserManagementModel({
    required this.id,
    this.remoteId,
    required this.tenantId,
    required this.branchId,
    this.branchName,
    required this.email,
    this.password,
    this.pin,
    required this.fullName,
    this.phone,
    required this.role,
    required this.isActive,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.createdByName,
    this.updatedBy,
    this.updatedByName,
  });

  factory UserManagementModel.fromJson(Map<String, dynamic> json) {
    return UserManagementModel(
      id: json['id'] ?? 0,
      remoteId: json['remote_id'] ?? json['id'],
      tenantId: json['tenant_id'] ?? 0,
      branchId: json['branch_id'] ?? 0,
      branchName: json['branch_name'],
      email: json['email'] ?? '',
      password: json['password'],
      pin: json['pin'],
      fullName: json['full_name'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? '',
      isActive: json['is_active'] ?? true,
      image: json['image'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      createdBy: json['created_by'],
      createdByName: json['created_by_name'],
      updatedBy: json['updated_by'],
      updatedByName: json['updated_by_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'remote_id': remoteId,
      'tenant_id': tenantId,
      'branch_id': branchId,
      'branch_name': branchName,
      'email': email,
      'password': password,
      'pin': pin,
      'full_name': fullName,
      'phone': phone,
      'role': role,
      'is_active': isActive,
      'image': image,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'created_by': createdBy,
      'created_by_name': createdByName,
      'updated_by': updatedBy,
      'updated_by_name': updatedByName,
    };
  }
}

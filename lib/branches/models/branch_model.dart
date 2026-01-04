class BranchModel {
  final int? id;
  final int tenantId;
  final String name;
  final String? code;
  final String? description;
  final String? address;
  final String? website;
  final String? email;
  final String? phone;
  final String? image;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;
  final int? createdBy;
  final String? createdByName;
  final int? updatedBy;
  final String? updatedByName;

  BranchModel({
    this.id,
    required this.tenantId,
    required this.name,
    this.code,
    this.description,
    this.address,
    this.website,
    this.email,
    this.phone,
    this.image,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.createdByName,
    this.updatedBy,
    this.updatedByName,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    // Support both GORM format (uppercase) and snake_case format
    return BranchModel(
      id: json['ID'] ?? json['id'],
      tenantId: json['tenant_id'],
      name: json['name'] ?? '',
      code: json['code'],
      description: json['description'],
      address: json['address'],
      website: json['website'],
      email: json['email'],
      phone: json['phone'],
      image: json['image'],
      isActive: json['is_active'],
      createdAt: json['CreatedAt'] ?? json['created_at'],
      updatedAt: json['UpdatedAt'] ?? json['updated_at'],
      createdBy: json['created_by'],
      createdByName: json['created_by_name'],
      updatedBy: json['updated_by'],
      updatedByName: json['updated_by_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'name': name,
      'code': code,
      'description': description,
      'address': address,
      'website': website,
      'email': email,
      'phone': phone,
      'image': image,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'created_by': createdBy,
      'created_by_name': createdByName,
      'updated_by': updatedBy,
      'updated_by_name': updatedByName,
    };
  }
}

class BranchListResponse {
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;
  final List<BranchModel> data;

  BranchListResponse({
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
    required this.data,
  });

  factory BranchListResponse.fromJson(Map<String, dynamic> json) {
    return BranchListResponse(
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? 20,
      totalItems: json['total_items'] ?? 0,
      totalPages: json['total_pages'] ?? 1,
      data:
          (json['data'] as List<dynamic>?)
              ?.map(
                (item) => BranchModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'page_size': pageSize,
      'total_items': totalItems,
      'total_pages': totalPages,
      'data': data.map((branch) => branch.toJson()).toList(),
    };
  }
}

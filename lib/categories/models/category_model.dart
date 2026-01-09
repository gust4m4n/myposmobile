class CategoryModel {
  final int? id;
  final int? remoteId;
  final int? tenantId;
  final String name;
  final String? description;
  final String? image;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;
  final int? createdBy;
  final String? createdByName;
  final int? updatedBy;
  final String? updatedByName;

  CategoryModel({
    this.id,
    this.remoteId,
    this.tenantId,
    required this.name,
    this.description,
    this.image,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.createdByName,
    this.updatedBy,
    this.updatedByName,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int?,
      remoteId: json['remote_id'] as int? ?? json['id'] as int?,
      tenantId: json['tenant_id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
      isActive: json['is_active'] as bool?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      createdBy: json['created_by'] as int?,
      createdByName: json['created_by_name'] as String?,
      updatedBy: json['updated_by'] as int?,
      updatedByName: json['updated_by_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (tenantId != null) 'tenant_id': tenantId,
      'name': name,
      if (description != null) 'description': description,
      if (image != null) 'image': image,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (createdBy != null) 'created_by': createdBy,
      if (createdByName != null) 'created_by_name': createdByName,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (updatedByName != null) 'updated_by_name': updatedByName,
    };
  }
}

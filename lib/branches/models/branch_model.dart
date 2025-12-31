class BranchModel {
  final int? id;
  final int tenantId;
  final String name;
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
    return BranchModel(
      id: json['id'],
      tenantId: json['tenant_id'],
      name: json['name'] ?? '',
      description: json['description'],
      address: json['address'],
      website: json['website'],
      email: json['email'],
      phone: json['phone'],
      image: json['image'],
      isActive: json['is_active'],
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
      'tenant_id': tenantId,
      'name': name,
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

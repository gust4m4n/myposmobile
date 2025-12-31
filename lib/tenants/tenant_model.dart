class TenantModel {
  final int? id;
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

  TenantModel({
    this.id,
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

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: json['id'],
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

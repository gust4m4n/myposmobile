class TncModel {
  final int id;
  final String title;
  final String content;
  final String version;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  TncModel({
    required this.id,
    required this.title,
    required this.content,
    required this.version,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TncModel.fromJson(Map<String, dynamic> json) {
    return TncModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      version: json['version'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'version': version,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

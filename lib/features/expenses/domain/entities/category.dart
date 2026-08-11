class Category {
  final String? id;
  final String name;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Category({
    this.id,
    required this.name,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  Category copyWith({
    String? id,
    String? name,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

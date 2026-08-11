import 'package:spend_wise/features/expenses/domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    super.id,
    required super.name,
    super.userId,
    super.createdAt,
    super.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String?,
      name: (json['name'] as String?) ?? 'Unnamed Category',
      userId: json['user_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      userId: category.userId,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
    );
  }
}

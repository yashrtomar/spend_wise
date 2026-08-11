import 'package:spend_wise/features/profile/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    super.id,
    required super.name,
    required super.monthlyBudget,
    super.preferences,
    required super.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      monthlyBudget: (json['monthly_budget'] as num).toDouble(),
      preferences: Map<String, dynamic>.from(
        json['preferences'] as Map,
      ),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'monthly_budget': monthlyBudget,
      'preferences': preferences,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      id: profile.id,
      name: profile.name,
      monthlyBudget: profile.monthlyBudget,
      preferences: profile.preferences,
      updatedAt: profile.updatedAt,
    );
  }
}

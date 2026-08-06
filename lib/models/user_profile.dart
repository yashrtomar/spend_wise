class UserProfile {
  final String? id;
  final String name;
  final double monthlyBudget;
  final Map<String, dynamic>? preferences;
  final DateTime updatedAt;

  const UserProfile({
    this.id,
    required this.name,
    required this.monthlyBudget,
    this.preferences,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
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

  UserProfile copyWith({
    String? id,
    String? name,
    double? monthlyBudget,
    Map<String, dynamic>? preferences,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      preferences: preferences ?? this.preferences,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
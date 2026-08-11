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

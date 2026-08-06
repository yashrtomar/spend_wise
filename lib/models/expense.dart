class Expense {
  final String? id;
  final String name;
  final double amount;
  final String category;
  final String? note;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Expense({
    this.id,
    required this.name,
    required this.amount,
    required this.category,
    this.note,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String?,
      name: (json['name'] as String?) ?? 'Unnamed Expense',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] != null
          ? (json['category'] is Map ? (json['category']['name']?.toString() ?? 'Other') : json['category'].toString())
          : (json['categories'] != null ? (json['categories']['name']?.toString() ?? 'Other') : 'Other'),
      note: json['note'] as String?,
      userId: json['user_id'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'category': category,
      'note': note,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Expense copyWith({
    String? id,
    String? name,
    double? amount,
    String? category,
    String? note,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      note: note ?? this.note,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
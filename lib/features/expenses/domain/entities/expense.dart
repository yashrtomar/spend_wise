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

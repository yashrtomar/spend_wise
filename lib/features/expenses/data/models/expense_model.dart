import 'package:spend_wise/features/expenses/domain/entities/expense.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    super.id,
    required super.name,
    required super.amount,
    required super.category,
    super.note,
    super.userId,
    super.createdAt,
    super.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String?,
      name: (json['name'] as String?) ?? 'Unnamed Expense',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] != null
          ? (json['category'] is Map
              ? (json['category']['name']?.toString() ?? 'Other')
              : json['category'].toString())
          : (json['categories'] != null
              ? (json['categories']['name']?.toString() ?? 'Other')
              : 'Other'),
      note: json['note'] as String?,
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
      'amount': amount,
      'category': category,
      'note': note,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      name: expense.name,
      amount: expense.amount,
      category: expense.category,
      note: expense.note,
      userId: expense.userId,
      createdAt: expense.createdAt,
      updatedAt: expense.updatedAt,
    );
  }
}

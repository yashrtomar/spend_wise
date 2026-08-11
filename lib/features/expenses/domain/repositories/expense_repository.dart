import 'package:spend_wise/features/expenses/domain/entities/expense.dart';
import 'package:spend_wise/features/expenses/domain/entities/expense_filter.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getExpenses({
    int? limit,
    int? offset,
    String? searchQuery,
    ExpenseFilter? filter,
    ExpenseSort? sort,
  });
  
  Future<Expense> addExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String id);
  Future<Map<String, double>> getExpensesByCategory(DateTime startDate, DateTime endDate);
  Future<List<Expense>> getRecentExpenses(int limit);
}

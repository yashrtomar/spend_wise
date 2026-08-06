import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/models/expense.dart';
import 'package:spend_wise/services/expenses_service.dart';

final expenseServiceProvider = Provider<ExpenseService>((ref) {
  return ExpenseService();
});

final expensesProvider = FutureProvider<List<Expense>>((ref) async {
  final expenseService = ref.watch(expenseServiceProvider);
  return expenseService.getExpenses();
});

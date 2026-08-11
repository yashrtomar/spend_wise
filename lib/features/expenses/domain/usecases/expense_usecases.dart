import 'package:spend_wise/features/expenses/domain/entities/expense.dart';
import 'package:spend_wise/features/expenses/domain/entities/expense_filter.dart';
import 'package:spend_wise/features/expenses/domain/repositories/expense_repository.dart';

class GetExpensesUseCase {
  final ExpenseRepository _repository;

  GetExpensesUseCase(this._repository);

  Future<List<Expense>> execute({
    int? limit,
    int? offset,
    String? searchQuery,
    ExpenseFilter? filter,
    ExpenseSort? sort,
  }) {
    return _repository.getExpenses(
      limit: limit,
      offset: offset,
      searchQuery: searchQuery,
      filter: filter,
      sort: sort,
    );
  }
}

class AddExpenseUseCase {
  final ExpenseRepository _repository;

  AddExpenseUseCase(this._repository);

  Future<Expense> execute(Expense expense) {
    return _repository.addExpense(expense);
  }
}

class UpdateExpenseUseCase {
  final ExpenseRepository _repository;

  UpdateExpenseUseCase(this._repository);

  Future<void> execute(Expense expense) {
    return _repository.updateExpense(expense);
  }
}

class DeleteExpenseUseCase {
  final ExpenseRepository _repository;

  DeleteExpenseUseCase(this._repository);

  Future<void> execute(String id) {
    return _repository.deleteExpense(id);
  }
}

class GetExpensesByCategoryUseCase {
  final ExpenseRepository _repository;

  GetExpensesByCategoryUseCase(this._repository);

  Future<Map<String, double>> execute(DateTime startDate, DateTime endDate) {
    return _repository.getExpensesByCategory(startDate, endDate);
  }
}

class GetRecentExpensesUseCase {
  final ExpenseRepository _repository;

  GetRecentExpensesUseCase(this._repository);

  Future<List<Expense>> execute(int limit) {
    return _repository.getRecentExpenses(limit);
  }
}

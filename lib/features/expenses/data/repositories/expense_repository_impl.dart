import 'package:spend_wise/features/expenses/data/datasources/expense_remote_datasource.dart';
import 'package:spend_wise/features/expenses/data/models/expense_model.dart';
import 'package:spend_wise/features/expenses/domain/entities/expense.dart';
import 'package:spend_wise/features/expenses/domain/entities/expense_filter.dart';
import 'package:spend_wise/features/expenses/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource _remoteDataSource;

  ExpenseRepositoryImpl(this._remoteDataSource);

  @override
  Future<Expense> addExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);
    return await _remoteDataSource.addExpense(model);
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _remoteDataSource.deleteExpense(id);
  }

  @override
  Future<List<Expense>> getExpenses({
    int? limit,
    int? offset,
    String? searchQuery,
    ExpenseFilter? filter,
    ExpenseSort? sort,
  }) async {
    return await _remoteDataSource.getExpenses(
      limit: limit,
      offset: offset,
      searchQuery: searchQuery,
      filter: filter,
      sort: sort,
    );
  }

  @override
  Future<Map<String, double>> getExpensesByCategory(DateTime startDate, DateTime endDate) async {
    return await _remoteDataSource.getExpensesByCategory(startDate, endDate);
  }

  @override
  Future<List<Expense>> getRecentExpenses(int limit) async {
    return await _remoteDataSource.getRecentExpenses(limit);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);
    await _remoteDataSource.updateExpense(model);
  }
}

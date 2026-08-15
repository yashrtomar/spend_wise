import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/features/expenses/data/datasources/expense_remote_datasource.dart';
import 'package:spend_wise/features/expenses/data/datasources/category_remote_datasource.dart';
import 'package:spend_wise/features/expenses/data/datasources/expense_local_datasource.dart';
import 'package:spend_wise/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:spend_wise/features/expenses/data/repositories/category_repository_impl.dart';
import 'package:spend_wise/features/expenses/domain/repositories/expense_repository.dart';
import 'package:spend_wise/features/expenses/domain/repositories/category_repository.dart';
import 'package:spend_wise/features/expenses/domain/usecases/expense_usecases.dart';
import 'package:spend_wise/features/expenses/domain/usecases/category_usecases.dart';

import 'package:spend_wise/services/sync_service.dart';

// Data Sources
final expenseRemoteDataSourceProvider = Provider<ExpenseRemoteDataSource>((ref) {
  return ExpenseRemoteDataSource();
});

final categoryRemoteDataSourceProvider = Provider<CategoryRemoteDataSource>((ref) {
  return CategoryRemoteDataSource();
});

final expenseLocalDataSourceProvider = Provider<ExpenseLocalDataSource>((ref) {
  return ExpenseLocalDataSource();
});

// Sync Service
final syncServiceProvider = Provider<SyncService>((ref) {
  final local = ref.watch(expenseLocalDataSourceProvider);
  final remote = ref.watch(expenseRemoteDataSourceProvider);
  return SyncService(local, remote)..init();
});

// Repositories
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final remoteDataSource = ref.watch(expenseRemoteDataSourceProvider);
  final localDataSource = ref.watch(expenseLocalDataSourceProvider);
  return ExpenseRepositoryImpl(remoteDataSource, localDataSource);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final dataSource = ref.watch(categoryRemoteDataSourceProvider);
  return CategoryRepositoryImpl(dataSource);
});

// Expense Use Cases
final getExpensesUseCaseProvider = Provider<GetExpensesUseCase>((ref) {
  return GetExpensesUseCase(ref.watch(expenseRepositoryProvider));
});
final addExpenseUseCaseProvider = Provider<AddExpenseUseCase>((ref) {
  return AddExpenseUseCase(ref.watch(expenseRepositoryProvider));
});
final updateExpenseUseCaseProvider = Provider<UpdateExpenseUseCase>((ref) {
  return UpdateExpenseUseCase(ref.watch(expenseRepositoryProvider));
});
final deleteExpenseUseCaseProvider = Provider<DeleteExpenseUseCase>((ref) {
  return DeleteExpenseUseCase(ref.watch(expenseRepositoryProvider));
});
final getExpensesByCategoryUseCaseProvider = Provider<GetExpensesByCategoryUseCase>((ref) {
  return GetExpensesByCategoryUseCase(ref.watch(expenseRepositoryProvider));
});
final getRecentExpensesUseCaseProvider = Provider<GetRecentExpensesUseCase>((ref) {
  return GetRecentExpensesUseCase(ref.watch(expenseRepositoryProvider));
});

// Category Use Cases
final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  return GetCategoriesUseCase(ref.watch(categoryRepositoryProvider));
});
final addCategoryUseCaseProvider = Provider<AddCategoryUseCase>((ref) {
  return AddCategoryUseCase(ref.watch(categoryRepositoryProvider));
});
final updateCategoryUseCaseProvider = Provider<UpdateCategoryUseCase>((ref) {
  return UpdateCategoryUseCase(ref.watch(categoryRepositoryProvider));
});
final deleteCategoryUseCaseProvider = Provider<DeleteCategoryUseCase>((ref) {
  return DeleteCategoryUseCase(ref.watch(categoryRepositoryProvider));
});
final deleteCategoryAndMoveExpensesUseCaseProvider = Provider<DeleteCategoryAndMoveExpensesUseCase>((ref) {
  return DeleteCategoryAndMoveExpensesUseCase(ref.watch(categoryRepositoryProvider));
});

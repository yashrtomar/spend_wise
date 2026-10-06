import 'package:spend_wise/features/expenses/data/datasources/category_local_datasource.dart';
import 'package:spend_wise/features/expenses/data/models/category_model.dart';
import 'package:spend_wise/features/expenses/domain/entities/category.dart';
import 'package:spend_wise/features/expenses/domain/repositories/category_repository.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:spend_wise/services/sync_service.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final SyncService _sync;
  final CategoryLocalDataSource _localDataSource;
  final _uuid = const Uuid();

  CategoryRepositoryImpl(this._localDataSource, this._sync);

  @override
  Future<Category> addCategory(Category category) async {
    // Generate UUID if not exists
    final categoryWithId = category.id == null || category.id!.isEmpty
        ? category.copyWith(id: _uuid.v4())
        : category;

    final model = CategoryModel.fromEntity(categoryWithId);
    await _localDataSource.addCategory(model);

    // Background sync
    unawaited(_sync.syncNow());

    return categoryWithId;
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _localDataSource.deleteCategory(id, deleteExpenses: true);
    unawaited(_sync.syncNow());
  }

  @override
  Future<void> deleteCategoryAndMoveExpenses(String id) async {
    await _localDataSource.deleteCategory(id, deleteExpenses: false);
    unawaited(_sync.syncNow());
  }

  @override
  Future<List<Category>> getCategories() async {
    return _localDataSource.getCategories();
  }

  @override
  Future<void> updateCategory(Category category) async {
    final model = CategoryModel.fromEntity(category);
    await _localDataSource.updateCategory(model);
    unawaited(_sync.syncNow());
  }
}

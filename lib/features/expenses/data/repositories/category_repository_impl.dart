import 'package:spend_wise/features/expenses/data/datasources/category_local_datasource.dart';
import 'package:spend_wise/features/expenses/data/datasources/category_remote_datasource.dart';
import 'package:spend_wise/features/expenses/data/models/category_model.dart';
import 'package:spend_wise/features/expenses/domain/entities/category.dart';
import 'package:spend_wise/features/expenses/domain/repositories/category_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' hide Category;

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;
  final CategoryLocalDataSource _localDataSource;
  final _uuid = const Uuid();

  CategoryRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Category> addCategory(Category category) async {
    // Generate UUID if not exists
    final categoryWithId = category.id == null || category.id!.isEmpty 
        ? category.copyWith(id: _uuid.v4()) 
        : category;
        
    final model = CategoryModel.fromEntity(categoryWithId);
    await _localDataSource.addCategory(model);
    
    // Background sync
    _syncCategoriesInBackground();
    
    return categoryWithId;
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _localDataSource.deleteCategory(id);
    _syncCategoriesInBackground();
  }

  @override
  Future<void> deleteCategoryAndMoveExpenses(String id) async {
    // First we mark as pending delete locally
    await _localDataSource.deleteCategory(id);
    // Note: The move logic relies on server-side logic in the remote datasource,
    // so we need to force a sync right away, or handle the moving of expenses locally.
    // For simplicity, we flag the category for delete and let the SyncService handle the remote move.
    _syncCategoriesInBackground();
  }

  @override
  Future<List<Category>> getCategories() async {
    final localCategories = await _localDataSource.getCategories();
    
    // Always fetch remote in background to keep local DB fresh
    _syncCategoriesInBackground();
    
    // Return local immediately for instant UI
    return localCategories;
  }

  @override
  Future<void> updateCategory(Category category) async {
    final model = CategoryModel.fromEntity(category);
    await _localDataSource.updateCategory(model);
    _syncCategoriesInBackground();
  }
  
  Future<void> _syncCategoriesInBackground() async {
    try {
      final remoteCategories = await _remoteDataSource.getCategories();
      for (var cat in remoteCategories) {
        // Add or update locally (if not pending upload)
        await _localDataSource.addCategory(cat, isSync: true);
      }
    } catch (e) {
      debugPrint("Background category sync failed: \$e");
    }
  }
}

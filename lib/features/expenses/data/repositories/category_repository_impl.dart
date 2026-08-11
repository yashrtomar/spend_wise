import 'package:spend_wise/features/expenses/data/datasources/category_remote_datasource.dart';
import 'package:spend_wise/features/expenses/data/models/category_model.dart';
import 'package:spend_wise/features/expenses/domain/entities/category.dart';
import 'package:spend_wise/features/expenses/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;

  CategoryRepositoryImpl(this._remoteDataSource);

  @override
  Future<Category> addCategory(Category category) async {
    final model = CategoryModel.fromEntity(category);
    return await _remoteDataSource.addCategory(model);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _remoteDataSource.deleteCategory(id);
  }

  @override
  Future<void> deleteCategoryAndMoveExpenses(String id) async {
    await _remoteDataSource.deleteCategoryAndMoveExpenses(id);
  }

  @override
  Future<List<Category>> getCategories() async {
    return await _remoteDataSource.getCategories();
  }

  @override
  Future<void> updateCategory(Category category) async {
    final model = CategoryModel.fromEntity(category);
    await _remoteDataSource.updateCategory(model);
  }
}

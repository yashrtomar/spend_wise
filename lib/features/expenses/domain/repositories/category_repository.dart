import 'package:spend_wise/features/expenses/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories();
  Future<Category> addCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
  Future<void> deleteCategoryAndMoveExpenses(String id);
}

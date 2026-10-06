import 'package:spend_wise/features/expenses/data/models/category_model.dart';
import 'package:spend_wise/services/sync_store.dart';
import 'package:spend_wise/utils/database_helper.dart';

class CategoryLocalDataSource {
  final SyncStore store;
  CategoryLocalDataSource(this.store);
  Future<List<CategoryModel>> getCategories() async {
    final db = await store.openDatabase();
    final rows = await db.query(
      'categories',
      where: '(user_id = ? OR user_id IS NULL) AND sync_status != ?',
      whereArgs: [store.userId, SyncStatus.pendingDelete],
      orderBy: 'name ASC, id ASC',
    );
    return rows.map(CategoryModel.fromJson).toList();
  }

  Future<void> addCategory(CategoryModel category) =>
      store.save('categories', category.toJson(), insert: true);
  Future<void> updateCategory(CategoryModel category) =>
      store.save('categories', category.toJson()..remove('created_at'));
  Future<void> deleteCategory(String id, {required bool deleteExpenses}) =>
      store.deleteCategory(id, deleteExpenses: deleteExpenses);
}

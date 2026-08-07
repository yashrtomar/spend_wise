import 'package:spend_wise/models/category.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoriesService {
  final _supabase = Supabase.instance.client;

  Future<List<Category>> getCategories() async {
    final response = await _supabase
        .schema('spendwise')
        .from('categories')
        .select()
        .order('name', ascending: true);

    return response.map<Category>((json) => Category.fromJson(json)).toList();
  }

  Future<void> addCategory(Category category) async {
    final userId = _supabase.auth.currentUser!.id;
    final data = category.toJson();
    data.remove('id');
    data.remove('created_at');
    data.remove('updated_at');
    data['user_id'] = userId;

    await _supabase.schema('spendwise').from('categories').insert(data);
  }

  Future<void> updateCategory(Category category) async {
    if (category.id == null) return;
    final userId = _supabase.auth.currentUser!.id;
    final data = category.toJson();
    data.remove('id');
    data.remove('created_at');
    data.remove('updated_at');
    data['user_id'] = userId;

    await _supabase
        .schema('spendwise')
        .from('categories')
        .update(data)
        .eq('id', category.id!)
        .eq('user_id', userId);
  }

  Future<void> deleteCategory(String id) async {
    final userId = _supabase.auth.currentUser!.id;
    
    await _supabase
        .schema('spendwise')
        .from('categories')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }

  Future<void> deleteCategoryAndExpenses(String categoryId) async {
    final userId = _supabase.auth.currentUser!.id;
    
    // 1. Delete expenses
    await _supabase
        .schema('spendwise')
        .from('expenses')
        .delete()
        .eq('category', categoryId)
        .eq('user_id', userId);

    // 2. Delete category
    await deleteCategory(categoryId);
  }

  Future<void> deleteCategoryAndMoveExpenses(String categoryId) async {
    final userId = _supabase.auth.currentUser!.id;
    
    // 1. Find 'Other' category
    final otherResponse = await _supabase
        .schema('spendwise')
        .from('categories')
        .select()
        .eq('user_id', userId)
        .ilike('name', 'Other')
        .limit(1);

    String otherCategoryId;
    if (otherResponse.isEmpty) {
      // Create it if it doesn't exist for some reason
      final newOther = await _supabase
          .schema('spendwise')
          .from('categories')
          .insert({'user_id': userId, 'name': 'Other'})
          .select()
          .single();
      otherCategoryId = newOther['id'] as String;
    } else {
      otherCategoryId = otherResponse.first['id'] as String;
    }

    // 2. Update expenses
    await _supabase
        .schema('spendwise')
        .from('expenses')
        .update({'category': otherCategoryId})
        .eq('category', categoryId)
        .eq('user_id', userId);

    // 3. Delete old category
    await deleteCategory(categoryId);
  }
}

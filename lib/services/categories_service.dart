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
}

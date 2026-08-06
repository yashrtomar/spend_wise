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
}

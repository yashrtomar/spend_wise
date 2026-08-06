import 'package:spend_wise/models/expense.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseService {
  final _supabase = Supabase.instance.client;

  Future<List<Expense>> getExpenses({int? limit, int? offset}) async {
    final userId = _supabase.auth.currentUser!.id;

    var query = _supabase
        .schema('spendwise')
        .from('expenses')
        .select('''
          *,
          categories (
            id,
            name
          )
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    if (limit != null && offset != null) {
      query = query.range(offset, offset + limit - 1);
    } else if (limit != null) {
      query = query.limit(limit);
    }

    final response = await query;

    return response.map<Expense>((json) => Expense.fromJson(json)).toList();
  }

  Future<void> addExpense(Expense expense) async {
    final userId = _supabase.auth.currentUser!.id;
    final data = expense.toJson();
    data.remove('id'); // DB auto-generates ID
    data.remove('created_at');
    data.remove('updated_at');
    data['user_id'] = userId;

    await _supabase.schema('spendwise').from('expenses').insert(data);
  }

  Future<void> updateExpense(Expense expense) async {
    if (expense.id == null) return;
    final userId = _supabase.auth.currentUser!.id;
    final data = expense.toJson();
    data.remove('id');
    data.remove('created_at');
    data.remove('updated_at');
    data['user_id'] = userId;

    await _supabase
        .schema('spendwise')
        .from('expenses')
        .update(data)
        .eq('id', expense.id!)
        .eq('user_id', userId);
  }

  Future<void> deleteExpense(String id) async {
    final userId = _supabase.auth.currentUser!.id;
    
    await _supabase
        .schema('spendwise')
        .from('expenses')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }
}

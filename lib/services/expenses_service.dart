import 'package:spend_wise/models/expense.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseService {
  final _supabase = Supabase.instance.client;

  Future<List<Expense>> getExpenses() async {
    final userId = _supabase.auth.currentUser!.id;

    final response = await _supabase
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

    return response.map<Expense>((json) => Expense.fromJson(json)).toList();
  }
}

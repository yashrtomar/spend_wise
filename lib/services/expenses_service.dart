import 'package:spend_wise/models/expense.dart';
import 'package:spend_wise/models/expense_filter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseService {
  final _supabase = Supabase.instance.client;

  Future<List<Expense>> getExpenses({
    int? limit,
    int? offset,
    String? searchQuery,
    ExpenseFilter? filter,
    ExpenseSort? sort,
  }) async {
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
        .eq('user_id', userId);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.ilike('name', '%$searchQuery%');
    }

    if (filter != null) {
      if (filter.startDate != null) {
        query = query.gte('created_at', filter.startDate!.toIso8601String());
      }
      if (filter.endDate != null) {
        // Add 1 day to include the entire end date if it's just the date
        final end = filter.endDate!.add(const Duration(days: 1));
        query = query.lt('created_at', end.toIso8601String());
      }
      if (filter.categories != null && filter.categories!.isNotEmpty) {
        query = query.inFilter('category', filter.categories!);
      }
      if (filter.minAmount != null) {
        query = query.gte('amount', filter.minAmount!);
      }
      if (filter.maxAmount != null) {
        query = query.lte('amount', filter.maxAmount!);
      }
    }

    var transformQuery = query.order('created_at', ascending: false);
    if (sort != null) {
      switch (sort) {
        case ExpenseSort.newest:
          transformQuery = query.order('created_at', ascending: false);
          break;
        case ExpenseSort.oldest:
          transformQuery = query.order('created_at', ascending: true);
          break;
        case ExpenseSort.amountHighest:
          transformQuery = query.order('amount', ascending: false);
          break;
        case ExpenseSort.amountLowest:
          transformQuery = query.order('amount', ascending: true);
          break;
      }
    }

    if (limit != null && offset != null) {
      transformQuery = transformQuery.range(offset, offset + limit - 1);
    } else if (limit != null) {
      transformQuery = transformQuery.limit(limit);
    }

    final response = await transformQuery;

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

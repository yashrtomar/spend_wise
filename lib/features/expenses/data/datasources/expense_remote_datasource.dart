import 'package:spend_wise/features/expenses/data/models/expense_model.dart';
import 'package:spend_wise/features/expenses/domain/entities/expense_filter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseRemoteDataSource {
  final SupabaseClient _supabase;

  ExpenseRemoteDataSource({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  Future<List<ExpenseModel>> getExpenses({
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

    return response.map<ExpenseModel>((json) => ExpenseModel.fromJson(json)).toList();
  }

  Future<ExpenseModel> addExpense(ExpenseModel expense) async {
    final userId = _supabase.auth.currentUser!.id;
    final data = expense.toJson();
    data.remove('id'); // DB auto-generates ID
    data.remove('created_at');
    data.remove('updated_at');
    data['user_id'] = userId;

    final response = await _supabase
        .schema('spendwise')
        .from('expenses')
        .insert(data)
        .select('''
          *,
          categories (
            id,
            name
          )
        ''').single();
    
    return ExpenseModel.fromJson(response);
  }

  Future<void> updateExpense(ExpenseModel expense) async {
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

  Future<Map<String, double>> getExpensesByCategory(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final userId = _supabase.auth.currentUser!.id;
    final end = endDate.add(const Duration(days: 1));

    final response = await _supabase
        .schema('spendwise')
        .from('expenses')
        .select('''
          amount,
          categories (
            name
          )
        ''')
        .eq('user_id', userId)
        .gte('created_at', startDate.toIso8601String())
        .lt('created_at', end.toIso8601String());

    final Map<String, double> categoryTotals = {};
    for (var item in response) {
      final amount = (item['amount'] as num).toDouble();
      final category = item['categories'] != null
          ? (item['categories']['name']?.toString() ?? 'Other')
          : 'Other';
      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
    }
    return categoryTotals;
  }

  Future<List<ExpenseModel>> getRecentExpenses(int limit) async {
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
        .order('created_at', ascending: false)
        .limit(limit);

    return response.map<ExpenseModel>((json) => ExpenseModel.fromJson(json)).toList();
  }
}

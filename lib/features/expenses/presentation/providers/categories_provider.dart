import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/features/expenses/domain/entities/category.dart';
import 'package:spend_wise/features/expenses/presentation/providers/expense_di_providers.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final getCategoriesUseCase = ref.watch(getCategoriesUseCaseProvider);
  return getCategoriesUseCase.execute();
});

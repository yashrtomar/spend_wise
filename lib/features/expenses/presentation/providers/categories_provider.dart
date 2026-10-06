import 'package:spend_wise/services/sync_providers.dart';
import 'package:spend_wise/services/sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/features/expenses/domain/entities/category.dart';
import 'package:spend_wise/features/expenses/presentation/providers/expense_di_providers.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final getCategoriesUseCase = ref.watch(getCategoriesUseCaseProvider);
  final sync = ref.watch(syncServiceProvider.notifier);
  await sync.readyForRead();
  final rows = await getCategoriesUseCase.execute();
  if (rows.isEmpty && !sync.hydrated) throw const FirstSyncException();
  return rows;
});

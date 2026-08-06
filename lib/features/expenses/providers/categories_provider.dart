import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/models/category.dart';
import 'package:spend_wise/services/categories_service.dart';

final categoriesServiceProvider = Provider<CategoriesService>((ref) {
  return CategoriesService();
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final categoriesService = ref.watch(categoriesServiceProvider);
  return categoriesService.getCategories();
});

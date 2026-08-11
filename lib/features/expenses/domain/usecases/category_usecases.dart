import 'package:spend_wise/features/expenses/domain/entities/category.dart';
import 'package:spend_wise/features/expenses/domain/repositories/category_repository.dart';

class GetCategoriesUseCase {
  final CategoryRepository _repository;

  GetCategoriesUseCase(this._repository);

  Future<List<Category>> execute() {
    return _repository.getCategories();
  }
}

class AddCategoryUseCase {
  final CategoryRepository _repository;

  AddCategoryUseCase(this._repository);

  Future<Category> execute(Category category) {
    return _repository.addCategory(category);
  }
}

class UpdateCategoryUseCase {
  final CategoryRepository _repository;

  UpdateCategoryUseCase(this._repository);

  Future<void> execute(Category category) {
    return _repository.updateCategory(category);
  }
}

class DeleteCategoryUseCase {
  final CategoryRepository _repository;

  DeleteCategoryUseCase(this._repository);

  Future<void> execute(String id) {
    return _repository.deleteCategory(id);
  }
}

class DeleteCategoryAndMoveExpensesUseCase {
  final CategoryRepository _repository;

  DeleteCategoryAndMoveExpensesUseCase(this._repository);

  Future<void> execute(String id) {
    return _repository.deleteCategoryAndMoveExpenses(id);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/features/expenses/providers/categories_provider.dart';
import 'package:spend_wise/features/expenses/providers/expenses_provider.dart';
import 'package:spend_wise/models/category.dart';
import 'package:spend_wise/services/categories_service.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/theme/app_spacing.dart';
import 'package:spend_wise/theme/app_typography.dart';
import 'package:spend_wise/utils/snackbar_helper.dart';
import 'package:spend_wise/widgets/danger_button.dart';
import 'package:spend_wise/widgets/secondary_button.dart';

class DeleteCategoryDialog extends ConsumerStatefulWidget {
  final Category category;

  const DeleteCategoryDialog({
    super.key,
    required this.category,
  });

  @override
  ConsumerState<DeleteCategoryDialog> createState() => _DeleteCategoryDialogState();
}

class _DeleteCategoryDialogState extends ConsumerState<DeleteCategoryDialog> {
  final _categoriesService = CategoriesService();
  bool _isDeleting = false;
  int _selectedOption = 0; // 0 for move to Other, 1 for delete entirely

  Future<void> _execute() async {
    if (_selectedOption == 0) {
      await _deleteCategoryAndMoveExpenses();
    } else {
      await _deleteCategoryAndExpenses();
    }
  }

  Future<void> _deleteCategoryAndExpenses() async {
    setState(() => _isDeleting = true);
    try {
      await _categoriesService.deleteCategoryAndExpenses(widget.category.id!);
      ref.invalidate(categoriesProvider);
      ref.invalidate(expensesProvider);
      ref.invalidate(paginatedExpensesProvider);
      await ref.read(categoriesProvider.future);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, 'Failed to delete category: $e');
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _deleteCategoryAndMoveExpenses() async {
    setState(() => _isDeleting = true);
    try {
      await _categoriesService.deleteCategoryAndMoveExpenses(widget.category.id!);
      ref.invalidate(categoriesProvider);
      ref.invalidate(expensesProvider);
      ref.invalidate(paginatedExpensesProvider);
      await ref.read(categoriesProvider.future);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, 'Failed to move expenses and delete category: $e');
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: colors.backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Delete Category?",
              style: AppTypography.lg.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "What would you like to do with the expenses currently in this category?",
              style: AppTypography.base.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            RadioGroup<int>(
              groupValue: _selectedOption,
              onChanged: (value) {
                if (_isDeleting) return;
                if (value != null) setState(() => _selectedOption = value);
              },
              child: Column(
                children: [
                  RadioListTile<int>(
                    contentPadding: EdgeInsets.zero,
                    activeColor: colors.primary,
                    title: Text(
                      "Move expenses to 'Other'",
                      style: AppTypography.base.copyWith(color: colors.textPrimary),
                    ),
                    value: 0,
                  ),
                  RadioListTile<int>(
                    contentPadding: EdgeInsets.zero,
                    activeColor: colors.error,
                    title: Text(
                      "Delete expenses permanently",
                      style: AppTypography.base.copyWith(color: colors.textPrimary),
                    ),
                    value: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              spacing: AppSpacing.sm,
              children: [
                Expanded(
                  child: SecondaryButton(
                    title: "Cancel",
                    onPressed: _isDeleting ? null : () => Navigator.pop(context),
                    height: 48,
                  ),
                ),
                Expanded(
                  child: _selectedOption == 0
                      ? DangerButton(
                          title: "Delete",
                          onPressed: _isDeleting ? null : _execute,
                          height: 48,
                        )
                      : DangerButton(
                          title: "Delete",
                          isLoading: _isDeleting,
                          onPressed: _isDeleting ? null : _execute,
                          height: 48,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

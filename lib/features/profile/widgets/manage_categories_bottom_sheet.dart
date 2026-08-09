import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spend_wise/features/expenses/providers/categories_provider.dart';
import 'package:spend_wise/models/category.dart';
import 'package:spend_wise/services/categories_service.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/theme/app_spacing.dart';
import 'package:spend_wise/theme/app_typography.dart';
import 'package:spend_wise/widgets/text_input.dart';
import 'package:spend_wise/features/profile/widgets/delete_category_dialog.dart';

class ManageCategoriesBottomSheet extends ConsumerStatefulWidget {
  const ManageCategoriesBottomSheet({super.key});

  @override
  ConsumerState<ManageCategoriesBottomSheet> createState() =>
      _ManageCategoriesBottomSheetState();
}

class _ManageCategoriesBottomSheetState
    extends ConsumerState<ManageCategoriesBottomSheet> {
  final _addController = TextEditingController();
  final _categoriesService = CategoriesService();
  bool _isAdding = false;
  String? _editingCategoryId;
  late final TextEditingController _editController = TextEditingController();

  @override
  void dispose() {
    _addController.dispose();
    _editController.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    final name = _addController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isAdding = true);
    try {
      await _categoriesService.addCategory(
        Category(name: name, createdAt: DateTime.now()),
      );
      _addController.clear();
      ref.invalidate(categoriesProvider);
      await ref.read(categoriesProvider.future);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add category: $e')));
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  Future<void> _updateCategory(Category category) async {
    final newName = _editController.text.trim();
    if (newName.isEmpty || newName == category.name) {
      setState(() => _editingCategoryId = null);
      return;
    }

    try {
      await _categoriesService.updateCategory(category.copyWith(name: newName));
      ref.invalidate(categoriesProvider);
      await ref.read(categoriesProvider.future);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update category: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _editingCategoryId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final categoriesAsync = ref.watch(categoriesProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Manage Categories",
                    style: AppTypography.lg.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: FaIcon(
                      FontAwesomeIcons.xmark,
                      color: colors.textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                spacing: AppSpacing.sm,
                children: [
                  Expanded(
                    child: TextInput(
                      hintText: "New Category Name",
                      controller: _addController,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _addCategory(),
                    ),
                  ),
                  InkWell(
                    onTap: _isAdding ? null : _addCategory,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: _isAdding
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const FaIcon(
                              FontAwesomeIcons.plus,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: categoriesAsync.when(
                  data: (categories) {
                    if (categories.isEmpty) {
                      return Center(
                        child: Text(
                          "No categories found.",
                          style: AppTypography.base.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: categories.length,
                      separatorBuilder: (context, index) => Divider(
                        color: colors.textSecondary.withValues(alpha: 0.5),
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isEditing = _editingCategoryId == category.id;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: isEditing
                                    ? TextInput(
                                        hintText: "Category Name",
                                        controller: _editController,
                                        textInputAction: TextInputAction.done,
                                        onFieldSubmitted: (_) =>
                                            _updateCategory(category),
                                        autofocus: true,
                                      )
                                    : Text(
                                        category.name,
                                        style: AppTypography.base.copyWith(
                                          color: colors.textPrimary,
                                        ),
                                      ),
                              ),
                              if (!isEditing) ...[
                                if (category.name.trim().toLowerCase() != 'other') ...[
                                  IconButton(
                                    onPressed: () {
                                      _editController.text = category.name;
                                      setState(
                                        () => _editingCategoryId = category.id,
                                      );
                                    },
                                    icon: FaIcon(
                                      FontAwesomeIcons.pen,
                                      color: colors.textSecondary,
                                      size: 16,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => showDialog(
                                      context: context,
                                      builder: (context) => DeleteCategoryDialog(category: category),
                                    ),
                                    icon: FaIcon(
                                      FontAwesomeIcons.trash,
                                      color: colors.error,
                                      size: 16,
                                    ),
                                  ),
                                ] else ...[
                                  // Placeholder for the 'Other' category to maintain row height
                                  IconButton(
                                    onPressed: null,
                                    icon: FaIcon(
                                      FontAwesomeIcons.lock,
                                      color: colors.textMuted.withValues(alpha: 0.3),
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 48),
                                ],
                              ] else ...[
                                IconButton(
                                  onPressed: () => _updateCategory(category),
                                  icon: FaIcon(
                                    FontAwesomeIcons.check,
                                    color: colors.primary,
                                    size: 20,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      setState(() => _editingCategoryId = null),
                                  icon: FaIcon(
                                    FontAwesomeIcons.xmark,
                                    color: colors.textSecondary,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Text(
                      'Error: $e',
                      style: TextStyle(color: colors.error),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

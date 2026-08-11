import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/features/expenses/presentation/providers/categories_provider.dart';
import 'package:spend_wise/features/expenses/presentation/providers/expenses_provider.dart';
import 'package:spend_wise/features/expenses/domain/entities/expense_filter.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/theme/app_spacing.dart';
import 'package:spend_wise/theme/app_typography.dart';
import 'package:spend_wise/widgets/primary_button.dart';
import 'package:spend_wise/widgets/text_input.dart';
import 'package:intl/intl.dart';

class ExpensesFilterBottomSheet extends ConsumerStatefulWidget {
  const ExpensesFilterBottomSheet({super.key});

  @override
  ConsumerState<ExpensesFilterBottomSheet> createState() =>
      _ExpensesFilterBottomSheetState();
}

class _ExpensesFilterBottomSheetState
    extends ConsumerState<ExpensesFilterBottomSheet> {
  late ExpenseFilter _draftFilter;

  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _draftFilter = ref.read(expenseFilterProvider);
    if (_draftFilter.minAmount != null) {
      _minAmountController.text = _draftFilter.minAmount!.toStringAsFixed(0);
    }
    if (_draftFilter.maxAmount != null) {
      _maxAmountController.text = _draftFilter.maxAmount!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final minAmountStr = _minAmountController.text.trim();
    final maxAmountStr = _maxAmountController.text.trim();

    _draftFilter = _draftFilter.copyWith(
      minAmount: double.tryParse(minAmountStr),
      maxAmount: double.tryParse(maxAmountStr),
      clearMinAmount: minAmountStr.isEmpty,
      clearMaxAmount: maxAmountStr.isEmpty,
    );

    ref.read(expenseFilterProvider.notifier).state = _draftFilter;
    Navigator.pop(context);
  }

  void _clearAll() {
    setState(() {
      _draftFilter = const ExpenseFilter();
      _minAmountController.clear();
      _maxAmountController.clear();
    });
  }

  void _setDateRange(String preset) async {
    final now = DateTime.now();
    DateTime? start;
    DateTime? end;

    if (preset == 'Today') {
      start = DateTime(now.year, now.month, now.day);
      end = start;
    } else if (preset == 'Yesterday') {
      start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
      end = start;
    } else if (preset == 'This Week') {
      start = DateTime(now.year, now.month, now.day - now.weekday + 1);
      end = start.add(const Duration(days: 6));
    } else if (preset == 'This Month') {
      start = DateTime(now.year, now.month, 1);
      end = DateTime(now.year, now.month + 1, 0);
    } else if (preset == 'This Year') {
      start = DateTime(now.year, 1, 1);
      end = DateTime(now.year, 12, 31);
    } else if (preset == 'Custom') {
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        initialDateRange: _draftFilter.startDate != null && _draftFilter.endDate != null
            ? DateTimeRange(start: _draftFilter.startDate!, end: _draftFilter.endDate!)
            : null,
      );
      if (picked != null) {
        start = picked.start;
        end = picked.end;
      } else {
        return;
      }
    }

    setState(() {
      _draftFilter = _draftFilter.copyWith(
        startDate: start,
        endDate: end,
        clearStartDate: start == null && preset != 'Custom',
        clearEndDate: end == null && preset != 'Custom',
      );
    });
  }

  bool _isDateRangeActive(String preset) {
    if (_draftFilter.startDate == null || _draftFilter.endDate == null) return false;
    final now = DateTime.now();
    final start = _draftFilter.startDate!;
    final end = _draftFilter.endDate!;

    if (preset == 'Today') {
      return start == DateTime(now.year, now.month, now.day) && start == end;
    } else if (preset == 'Yesterday') {
      final yesterday = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
      return start == yesterday && start == end;
    } else if (preset == 'This Week') {
      final weekStart = DateTime(now.year, now.month, now.day - now.weekday + 1);
      return start == weekStart && end == weekStart.add(const Duration(days: 6));
    } else if (preset == 'This Month') {
      return start == DateTime(now.year, now.month, 1) &&
          end == DateTime(now.year, now.month + 1, 0);
    } else if (preset == 'This Year') {
      return start == DateTime(now.year, 1, 1) && end == DateTime(now.year, 12, 31);
    }
    return false;
  }

  bool _isCustomDateActive() {
    if (_draftFilter.startDate == null || _draftFilter.endDate == null) return false;
    return !_isDateRangeActive('Today') &&
        !_isDateRangeActive('Yesterday') &&
        !_isDateRangeActive('This Week') &&
        !_isDateRangeActive('This Month') &&
        !_isDateRangeActive('This Year');
  }

  void _toggleCategory(String categoryId) {
    final current = List<String>.from(_draftFilter.categories ?? []);
    if (current.contains(categoryId)) {
      current.remove(categoryId);
    } else {
      current.add(categoryId);
    }
    setState(() {
      _draftFilter = _draftFilter.copyWith(
        categories: current,
        clearCategories: current.isEmpty,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final categoriesAsync = ref.watch(categoriesProvider);

    return Container(
      decoration: BoxDecoration(
        color: colors.backgroundScreen,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Filters",
                style: AppTypography.lg.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!_draftFilter.isEmpty || _minAmountController.text.isNotEmpty || _maxAmountController.text.isNotEmpty)
                TextButton(
                  onPressed: _clearAll,
                  child: Text(
                    "Clear All",
                    style: TextStyle(color: colors.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Date Range",
                    style: AppTypography.sm.copyWith(
                      color: colors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildDateChip('Today'),
                      _buildDateChip('Yesterday'),
                      _buildDateChip('This Week'),
                      _buildDateChip('This Month'),
                      _buildDateChip('This Year'),
                      _buildCustomDateChip(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Categories",
                    style: AppTypography.sm.copyWith(
                      color: colors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  categoriesAsync.when(
                    data: (categories) {
                      if (categories.isEmpty) {
                        return Text(
                          "No categories found",
                          style: TextStyle(color: colors.textMuted),
                        );
                      }
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: categories.map((cat) {
                          final isSelected = _draftFilter.categories?.contains(cat.id) ?? false;
                          return ChoiceChip(
                            label: Text(cat.name),
                            selected: isSelected,
                            onSelected: (_) => _toggleCategory(cat.id!),
                            selectedColor: colors.primary.withValues(alpha: 0.1),
                            labelStyle: TextStyle(
                              color: isSelected ? colors.primary : colors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                            backgroundColor: colors.backgroundCard,
                            side: BorderSide(
                              color: isSelected ? colors.primary : colors.border,
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => const Text("Error loading categories"),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Amount Range",
                    style: AppTypography.sm.copyWith(
                      color: colors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextInput(
                          controller: _minAmountController,
                          hintText: "Min",
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text("-", style: TextStyle(color: colors.textMuted)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextInput(
                          controller: _maxAmountController,
                          hintText: "Max",
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            title: "Apply Filters",
            onPressed: _applyFilter,
          ),
        ],
      ),
    );
  }

  Widget _buildDateChip(String label) {
    final isSelected = _isDateRangeActive(label);
    final colors = context.colors;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        if (isSelected) {
          setState(() {
            _draftFilter = _draftFilter.copyWith(
              clearStartDate: true,
              clearEndDate: true,
            );
          });
        } else {
          _setDateRange(label);
        }
      },
      selectedColor: colors.primary.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: isSelected ? colors.primary : colors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
      backgroundColor: colors.backgroundCard,
      side: BorderSide(
        color: isSelected ? colors.primary : colors.border,
      ),
    );
  }

  Widget _buildCustomDateChip() {
    final isSelected = _isCustomDateActive();
    final colors = context.colors;
    
    String label = 'Custom';
    if (isSelected) {
      final formatter = DateFormat('MMM d');
      label = '${formatter.format(_draftFilter.startDate!)} - ${formatter.format(_draftFilter.endDate!)}';
    }

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        if (isSelected) {
          setState(() {
            _draftFilter = _draftFilter.copyWith(
              clearStartDate: true,
              clearEndDate: true,
            );
          });
        } else {
          _setDateRange('Custom');
        }
      },
      selectedColor: colors.primary.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: isSelected ? colors.primary : colors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
      backgroundColor: colors.backgroundCard,
      side: BorderSide(
        color: isSelected ? colors.primary : colors.border,
      ),
    );
  }
}

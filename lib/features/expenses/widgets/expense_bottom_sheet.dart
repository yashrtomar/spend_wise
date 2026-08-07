import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/features/expenses/providers/categories_provider.dart';
import 'package:spend_wise/features/expenses/providers/expenses_provider.dart';
import 'package:spend_wise/models/expense.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/theme/app_spacing.dart';
import 'package:spend_wise/theme/app_typography.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spend_wise/widgets/danger_button.dart';
import 'package:spend_wise/widgets/dropdown.dart';
import 'package:spend_wise/widgets/primary_button.dart';
import 'package:spend_wise/widgets/text_input.dart';

class ExpenseBottomSheet extends ConsumerStatefulWidget {
  final Expense? expense;
  const ExpenseBottomSheet({super.key, this.expense});

  @override
  ConsumerState<ExpenseBottomSheet> createState() => _ExpenseBottomSheetState();
}

class _ExpenseBottomSheetState extends ConsumerState<ExpenseBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  final _nameFocus = FocusNode();
  final _amountFocus = FocusNode();
  final _noteFocus = FocusNode();

  String? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _nameController.text = widget.expense!.name;
      _amountController.text = widget.expense!.amount.toString();
      _selectedCategory = widget.expense!.category;
      if (widget.expense!.note != null) {
        _noteController.text = widget.expense!.note!;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();

    _nameFocus.dispose();
    _amountFocus.dispose();
    _noteFocus.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _isLoading) {
      return;
    }

    setState(() => _isLoading = true);
    final expenseService = ref.read(expenseServiceProvider);
    final expense = Expense(
      id: widget.expense?.id,
      name: _nameController.text.trim(),
      amount: double.parse(_amountController.text),
      category: _selectedCategory!,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    try {
      if (widget.expense == null) {
        await expenseService.addExpense(expense);
      } else {
        await expenseService.updateExpense(expense);
      }

      ref.invalidate(expensesProvider);
      ref.invalidate(paginatedExpensesProvider);

      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _delete() async {
    if (widget.expense?.id == null || _isLoading) return;

    setState(() => _isLoading = true);
    final expenseService = ref.read(expenseServiceProvider);

    try {
      await expenseService.deleteExpense(widget.expense!.id!);

      ref.invalidate(expensesProvider);
      ref.invalidate(paginatedExpensesProvider);

      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final categoriesAsync = ref.watch(categoriesProvider);
    final categoryItems = categoriesAsync.value ?? [];
    final validIds = categoryItems.map((c) => c.id).whereType<String>().toSet();
    final isSelectedValid = _selectedCategory != null && validIds.contains(_selectedCategory);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 28,
          right: 28,
          bottom: MediaQuery.of(context).viewInsets.bottom + 8,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.expense == null ? "New Expense" : "Edit Expense",
                  style: AppTypography.lg.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.expense == null
                      ? "Enter details to record a new transaction"
                      : "Update your transaction details below",
                  style: AppTypography.sm.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextInput(
                  hintText: "Expense Name",
                  controller: _nameController,
                  focusNode: _nameFocus,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Expense name is required";
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_amountFocus);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextInput(
                  hintText: "Amount",
                  controller: _amountController,
                  focusNode: _amountFocus,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Amount is required";
                    }
                    if (double.tryParse(value) == null) {
                      return "Enter a valid numeric amount";
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_noteFocus);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Dropdown<String>(
                  hintText: categoriesAsync.isLoading
                      ? "Loading categories..."
                      : "Select Category",
                  value: isSelectedValid ? _selectedCategory : null,
                  selectedItemBuilder: (BuildContext context) {
                    return categoryItems
                        .where((c) => c.id != null)
                        .map<Widget>((category) {
                      return Text(
                        category.name,
                        style: AppTypography.base.copyWith(
                          color: colors.textPrimary,
                        ),
                      );
                    }).toList();
                  },
                  items: categoryItems
                      .where((c) => c.id != null)
                      .map(
                        (category) => DropdownMenuItem<String>(
                          value: category.id!,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: colors.textSecondary.withValues(alpha: 0.1),
                                  width: 1,
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: 14,
                            ),
                            child: Text(
                              category.name,
                              style: AppTypography.base.copyWith(
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: categoriesAsync.isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                  validator: (value) {
                    if (value == null) {
                      return "Please select a category";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextInput(
                  hintText: "Note (optional)",
                  controller: _noteController,
                  focusNode: _noteFocus,
                  textInputAction: TextInputAction.done,
                  maxLines: 3,
                  onFieldSubmitted: (_) => _save(),
                ),
                const SizedBox(height: 28),
                if (widget.expense == null)
                  PrimaryButton(
                    title: _isLoading ? "Saving..." : "Save Expense",
                    onPressed: _isLoading ? () {} : _save,
                    height: 48,
                  )
                else
                  Row(
                    spacing: AppSpacing.sm,
                    children: [
                      Expanded(
                        child: DangerButton(
                          title: _isLoading ? "Wait..." : "Delete",
                          icon: FontAwesomeIcons.trashCan,
                          isLoading: _isLoading,
                          onPressed: _delete,
                          height: 48,
                        ),
                      ),
                      Expanded(
                        child: PrimaryButton(
                          title: _isLoading ? "Saving..." : "Update",
                          onPressed: _isLoading ? () {} : _save,
                          height: 48,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

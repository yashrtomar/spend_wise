import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/features/expenses/providers/categories_provider.dart';
import 'package:spend_wise/models/expense.dart';
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
  String? _selectedCategory;
  final _noteController = TextEditingController();

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
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    print("Name: ${_nameController.text}");
    print("Amount: ${_amountController.text}");
    print("Category: $_selectedCategory");
    print("Note: ${_noteController.text}");

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final categoryItems = categoriesAsync.value ?? [];
    final validIds = categoryItems.map((c) => c.id).whereType<String>().toSet();
    final isSelectedValid = _selectedCategory != null && validIds.contains(_selectedCategory);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.expense == null ? "Add Expense" : "Edit Expense",
                  // style: context.colors.headlineSmall,
                ),
                const SizedBox(height: 24),
                TextInput(
                  hintText: "Expense Name",
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Required";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextInput(
                  hintText: "Amount",
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  isAmount: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Required";
                    }
                    if (double.tryParse(value) == null) {
                      return "Invalid amount";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                Dropdown<String>(
                  label: "Category",
                  hintText: categoriesAsync.isLoading
                      ? "Loading categories..."
                      : "Select Category",
                  value: isSelectedValid ? _selectedCategory : null,
                  items: categoryItems
                      .where((c) => c.id != null)
                      .map(
                        (category) => DropdownMenuItem<String>(
                          value: category.id!,
                          child: Text(category.name),
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
                const SizedBox(height: 16),
                TextInput(
                  hintText: "Note (optional)",
                  controller: _noteController,
                  maxLines: 4,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(title: "Save Expense", onPressed: _save),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

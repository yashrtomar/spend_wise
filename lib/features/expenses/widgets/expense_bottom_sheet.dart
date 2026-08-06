import 'package:flutter/material.dart';
import 'package:spend_wise/models/expense.dart';
import 'package:spend_wise/widgets/dropdown.dart';
import 'package:spend_wise/widgets/primary_button.dart';
import 'package:spend_wise/widgets/text_input.dart';

class ExpenseBottomSheet extends StatefulWidget {
  const ExpenseBottomSheet({super.key, Expense? expense});

  @override
  State<ExpenseBottomSheet> createState() => _ExpenseBottomSheetState();
}

class _ExpenseBottomSheetState extends State<ExpenseBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedCategory;
  final _noteController = TextEditingController();

  final List<String> _categories = [
    "Food",
    "Transport",
    "Shopping",
    "Bills",
    "Entertainment",
    "Health",
    "Other",
  ];

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
    print("Category: ${_selectedCategory}");
    print("Note: ${_noteController.text}");

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
                  "Add Expense",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                const SizedBox(height: 24),

                TextInput(
                  label: "Expense Name",
                  hintText: "Starbucks Coffee",
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
                  label: "Amount",

                  hintText: "0.00",

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

                  hintText: "Select Category",

                  value: _selectedCategory,

                  items: _categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),

                  onChanged: (value) {
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
                  label: "Note",
                  hintText: "Optional",

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

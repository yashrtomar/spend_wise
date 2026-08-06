import 'package:flutter/material.dart';
import 'package:spend_wise/features/expenses/widgets/add_expense_button.dart';
import 'package:spend_wise/features/expenses/widgets/budget_card.dart';
import 'package:spend_wise/features/expenses/widgets/expense_bottom_sheet.dart';
import 'package:spend_wise/features/expenses/widgets/expense_list.dart';
import 'package:spend_wise/features/expenses/widgets/greet_header.dart';
import 'package:spend_wise/models/expense.dart';
import 'package:spend_wise/widgets/section_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // Future<void> _logout() async {
  //   print("Logout");
  // }

  Future<void> _openExpenseSheet({
    Expense? expense,
  }) async {

    await showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      useSafeArea: true,

      showDragHandle: true,

      builder: (_) => ExpenseBottomSheet(
        expense: expense,
      ),
    );

    print("Refresh expenses");
  }

  @override
  Widget build(BuildContext context) {

    // temporary

    const budget = 5000.0;
    const remaining = 3250.0;

    final expenses = <Expense>[];

    return Scaffold(

      body: SafeArea(

        child: Column(

          children: [

            GreetHeader(
              name: "Yash",
            ),

            Expanded(

              child: ListView(

                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),

                children: [

                  BudgetCard(
                    budget: budget,
                    remaining: remaining,
                  ),

                  ExpenseSectionHeader(
                    title: "Recent Expenses",

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text("View All"),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                  ),

                  ExpenseList(
                    expenses: expenses,

                    onExpensePressed: (expense) {
                      _openExpenseSheet(
                        expense: expense,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: AddExpenseButton(

        onPressed: () {

          _openExpenseSheet();

        },

      ),
    );
  }
}
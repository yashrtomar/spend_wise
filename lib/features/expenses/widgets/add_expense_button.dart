import 'package:flutter/material.dart';
import 'package:spend_wise/theme/app_colors.dart';

class AddExpenseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddExpenseButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: colors.primary,
      foregroundColor: colors.textInverse,
      child: const Icon(
        Icons.add,
        size: 36,
      ),
    );
  }
}
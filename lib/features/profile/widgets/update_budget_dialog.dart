import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/features/profile/providers/profile_provider.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/theme/app_radius.dart';
import 'package:spend_wise/theme/app_spacing.dart';
import 'package:spend_wise/theme/app_typography.dart';
import 'package:spend_wise/widgets/primary_button.dart';
import 'package:spend_wise/widgets/text_input.dart';

class UpdateBudgetDialog extends ConsumerStatefulWidget {
  final double currentBudget;

  const UpdateBudgetDialog({super.key, required this.currentBudget});

  @override
  ConsumerState<UpdateBudgetDialog> createState() => _UpdateBudgetDialogState();
}

class _UpdateBudgetDialogState extends ConsumerState<UpdateBudgetDialog> {
  late final TextEditingController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentBudget.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = double.tryParse(_controller.text);
    if (value == null || value < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid budget amount')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(profileProvider.notifier).updateBudget(value);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update budget: $e')),
        );
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

    return Dialog(
      backgroundColor: colors.backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lg,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Update Monthly Budget",
              style: AppTypography.lg.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextInput(
              hintText: "Budget Amount",
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: AppTypography.base.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: PrimaryButton(
                    title: _isLoading ? "Wait..." : "Save",
                    onPressed: _isLoading ? null : _save,
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/features/profile/providers/profile_provider.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/theme/app_radius.dart';
import 'package:spend_wise/theme/app_spacing.dart';
import 'package:spend_wise/theme/app_typography.dart';
import 'package:spend_wise/widgets/primary_button.dart';
import 'package:spend_wise/widgets/secondary_button.dart';
import 'package:spend_wise/widgets/text_input.dart';
import 'package:spend_wise/utils/snackbar_helper.dart';

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
      SnackbarHelper.showError(context, 'Please enter a valid budget amount');
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
        SnackbarHelper.showError(context, 'Failed to update budget: $e');
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: colors.backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lg,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
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
              spacing: AppSpacing.sm,
              children: [
                Expanded(
                  child: SecondaryButton(
                    title: "Cancel",
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    height: 48,
                  ),
                ),
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

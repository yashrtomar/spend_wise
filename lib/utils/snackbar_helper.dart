import 'package:flutter/material.dart';
import 'package:spend_wise/theme/app_colors.dart';

class SnackbarHelper {
  static void showSuccess(BuildContext context, String message) {
    _showSnackbar(context, message, context.colors.success.withValues(alpha: 0.8));
  }

  static void showError(BuildContext context, String message) {
    _showSnackbar(context, message, context.colors.error.withValues(alpha: 0.8));
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackbar(context, message, context.colors.primary.withValues(alpha: 0.8));
  }

  static void _showSnackbar(BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

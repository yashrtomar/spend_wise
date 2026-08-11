import 'package:flutter/material.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/theme/app_radius.dart';

class SocialButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;

  const SocialButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          side: BorderSide(color: colors.border),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.md,
          ),
        ),
        child: Center(child: icon),
      ),
    );
  }
}
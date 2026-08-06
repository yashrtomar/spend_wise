import 'package:flutter/material.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/theme/app_radius.dart';

class SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const SettingsCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return Container(
      decoration: BoxDecoration(
        color: colors.backgroundCard,
        borderRadius: AppRadius.lg,
        border: Border.all(
          color: colors.textSecondary.withValues(alpha: 0.08),
        ),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.lg,
        child: Column(
          children: children,
        ),
      ),
    );
  }
}

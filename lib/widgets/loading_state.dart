import 'package:flutter/material.dart';
import 'package:spend_wise/theme/app_colors.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: context.colors.primary,
      ),
    );
  }
}

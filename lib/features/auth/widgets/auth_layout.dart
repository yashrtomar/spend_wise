import 'package:flutter/material.dart';
import 'package:spend_wise/features/auth/widgets/auth_header.dart';
import 'package:spend_wise/theme/app_spacing.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;

  const AuthLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AuthHeader(),
              const SizedBox(height: AppSpacing.lg),
              child, // login form
            ],
          ),
        ),
      ),
    );
  }
}

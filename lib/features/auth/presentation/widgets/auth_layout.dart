import 'package:flutter/material.dart';
import 'package:spend_wise/features/auth/presentation/widgets/auth_header.dart';
import 'package:spend_wise/features/auth/presentation/widgets/auth_background_pattern.dart';
import 'package:spend_wise/theme/app_spacing.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;

  const AuthLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      body: Stack(
        children: [
          const Positioned.fill(
            child: AuthBackgroundPattern(),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const AuthHeader(),
                        const SizedBox(height: 48), // Increased gap here
                        child, // login form
                        const SizedBox(height: AppSpacing.xl), // Add breathing room at bottom
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

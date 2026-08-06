import 'package:flutter/material.dart';

import 'package:spend_wise/features/auth/widgets/social_button.dart';
import 'package:spend_wise/theme/app_spacing.dart';

class OauthButtonRow extends StatelessWidget {
  final VoidCallback? onGooglePressed;
  final VoidCallback? onApplePressed;

  const OauthButtonRow({
    super.key,
    this.onGooglePressed,
    this.onApplePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SocialButton(
            icon: const Icon(Icons.g_mobiledata),
            onPressed: onGooglePressed ??
                () => debugPrint("Google Login"),
          ),
        ),

        const SizedBox(width: AppSpacing.xs),

        Expanded(
          child: SocialButton(
            icon: const Icon(Icons.apple),
            onPressed: onApplePressed ??
                () => debugPrint("Apple Login"),
          ),
        ),
      ],
    );
  }
}
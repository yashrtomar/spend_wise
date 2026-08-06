import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:spend_wise/features/auth/widgets/social_button.dart';
import 'package:spend_wise/theme/app_spacing.dart';
import 'package:spend_wise/theme/app_colors.dart';

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
    final colors = context.colors;
    return Row(
      children: [
        Expanded(
          child: SocialButton(
            icon: FaIcon(FontAwesomeIcons.google, color: colors.textPrimary),
            onPressed: onGooglePressed ??
                () => debugPrint("Google Login"),
          ),
        ),

        const SizedBox(width: AppSpacing.xs),

        Expanded(
          child: SocialButton(
            icon: FaIcon(FontAwesomeIcons.apple, size: 28, color: colors.textPrimary,),
            onPressed: onApplePressed ??
                () => debugPrint("Apple Login"),
          ),
        ),
      ],
    );
  }
}
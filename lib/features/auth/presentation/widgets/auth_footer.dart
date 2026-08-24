import 'package:flutter/material.dart';

import '../../../../config/theme/app_spacing.dart';
import '../../../../core/extensions/context_extension.dart';

/// "New here? Create an account".
///
/// One centred line, with only the action tinted. It is a real `TextButton`
/// rather than a tappable `Text`, which is where the 48pt target and the
/// pressed state come from.
class AuthFooter extends StatelessWidget {
  final String prompt;
  final String action;
  final VoidCallback onPressed;

  const AuthFooter({super.key, required this.prompt, required this.action, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppInsets.authHorizontal,
      child: Row(
        spacing: AppSpacing.md,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(child: Text(prompt, style: context.styles.footerPrompt)),
          TextButton(onPressed: onPressed, child: Text(action)),
        ],
      ),
    );
  }
}

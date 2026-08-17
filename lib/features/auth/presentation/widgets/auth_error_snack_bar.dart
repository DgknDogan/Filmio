import 'package:flutter/material.dart';

import '../../../../config/theme/app_spacing.dart';
import '../../../../core/extensions/context_extension.dart';

/// The bar both auth screens show when a sign-in or sign-up is rejected.
///
/// The failure is a whole-screen outcome, not one field's problem, so it is
/// announced above the form rather than under a field — with an icon, because
/// colour alone is not a signal everyone receives.
SnackBar authErrorSnackBar(BuildContext context, String message) {
  return SnackBar(
    content: Row(
      children: [
        Icon(Icons.error_outline_rounded, color: context.palette.danger, size: AppSpacing.xxl),
        AppGap.horizontal(AppSpacing.md),
        Expanded(child: Text(message)),
      ],
    ),
  );
}

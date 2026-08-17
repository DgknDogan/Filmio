import 'package:flutter/material.dart';

import '../../config/theme/app_spacing.dart';
import '../extensions/context_extension.dart';

/// What a failed state renders: the message the failure carries, and a way to
/// try again. Every screen uses this rather than its own centred `Text`.
class AppErrorView extends StatelessWidget {
  final String message;

  /// Omit when there is nothing sensible to retry.
  final VoidCallback? onRetry;

  const AppErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppInsets.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: context.palette.textSecondary, size: AppSpacing.huge),
            AppGap.vertical(AppSpacing.md),
            Text(message, textAlign: TextAlign.center, style: context.textTheme.titleSmall),
            if (onRetry != null) ...[
              AppGap.vertical(AppSpacing.md),
              TextButton(onPressed: onRetry, child: Text(context.l10n.tryAgain)),
            ],
          ],
        ),
      ),
    );
  }
}

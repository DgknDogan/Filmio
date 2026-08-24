import 'package:flutter/material.dart';

import '../../config/theme/app_spacing.dart';
import '../extensions/context_extension.dart';
import 'custom_button.dart';

/// The app's one modal shape.
///
/// Everything that used to be an `AlertDialog` comes through here instead. A
/// stock dialog is drawn by Material, not by this app: square-ish corners, a
/// grey scrim, buttons crowded into a corner, and none of it answering to the
/// palette. A sheet is what the app already uses for filters and for the
/// details screen, so a choice arriving from the bottom is the shape people
/// have already seen.
///
/// Two forms, both built from the same chrome:
///
/// * [showActions] — a list of things to pick, one tap each. The menu on a
///   review, and the reasons for reporting one.
/// * [showConfirm] — a question with a primary answer and a way out, plus
///   whatever the caller needs in between (a password field, say).
class AppSheet extends StatelessWidget {
  final String title;

  /// The line under the title. Optional: a list of plain choices explains
  /// itself.
  final String? message;

  /// What goes between the message and the bottom of the sheet.
  final Widget body;

  const AppSheet({super.key, required this.title, required this.body, this.message});

  /// A list of choices. Returns the value of the one picked, or null if the
  /// sheet was dismissed.
  static Future<T?> showActions<T>(
    BuildContext context, {
    required String title,
    String? message,
    required List<AppSheetAction<T>> actions,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => AppSheet(
        title: title,
        message: message,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final action in actions)
              _ActionRow(
                action: action,
                onTap: () => Navigator.of(sheetContext).pop(action.value),
              ),
          ],
        ),
      ),
    );
  }

  /// A question with one primary answer. Returns true when it was taken, and
  /// null when the sheet was dismissed any other way.
  ///
  /// Deliberately takes no widgets from the caller. A sheet that needs a field
  /// needs a controller, and a controller owned outside the sheet outlives the
  /// future this returns — the sheet is still on screen through its dismissal
  /// animation after the future completes, so disposing it there is a use
  /// after free. A sheet with a field builds its own [AppSheet] and owns the
  /// controller itself; see `showDeleteAccountSheet`.
  static Future<bool?> showConfirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
    bool isDestructive = false,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => AppSheet(
        title: title,
        message: message,
        body: AppSheetActions(
          confirmLabel: confirmLabel,
          cancelLabel: cancelLabel,
          isDestructive: isDestructive,
          onConfirm: () => Navigator.of(sheetContext).pop(true),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        // Lifts the sheet clear of the keyboard when it carries a field.
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.sm, AppSpacing.xxl, AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.styles.sectionTitle),
                if (message case final message?) ...[
                  AppGap.vertical(AppSpacing.sm),
                  Text(message, style: context.styles.paragraph),
                ],
                AppGap.vertical(AppSpacing.lg),
                body,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One choice in an action sheet.
class AppSheetAction<T> {
  final T value;
  final String label;
  final IconData? icon;

  /// Draws the row in the danger colour. For the one action that cannot be
  /// undone, not for every action somebody might regret.
  final bool isDestructive;

  const AppSheetAction({
    required this.value,
    required this.label,
    this.icon,
    this.isDestructive = false,
  });
}

class _ActionRow extends StatelessWidget {
  final AppSheetAction action;
  final VoidCallback onTap;

  const _ActionRow({required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final colour = action.isDestructive ? palette.danger : palette.textPrimary;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: Container(
          width: double.infinity,
          // A row of a sheet is a target before it is a label: 52 high, so it
          // clears the 44pt minimum with the padding the system uses.
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: AppRadius.smAll,
            border: Border.all(color: palette.controlBorder),
          ),
          child: Row(
            children: [
              if (action.icon case final icon?) ...[
                Icon(icon, size: AppSpacing.xl, color: colour),
                AppGap.horizontal(AppSpacing.md),
              ],
              Expanded(
                child: Text(action.label, style: context.textTheme.bodyMedium?.copyWith(color: colour)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The buttons at the foot of a sheet that asks a question.
///
/// The primary action is the app's own button so it reads the way every other
/// primary action does; the way out is the quiet line under it, never a pair of
/// matching text buttons in a corner.
class AppSheetActions extends StatelessWidget {
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;
  final VoidCallback onConfirm;

  const AppSheetActions({
    super.key,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.onConfirm,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Destructive actions do not get the accent: an outline in the danger
        // colour, so the button that deletes an account cannot be mistaken for
        // the one that creates one.
        if (isDestructive)
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: palette.danger,
              side: BorderSide(color: palette.danger),
            ),
            onPressed: onConfirm,
            child: Text(confirmLabel),
          )
        else
          CustomButton(text: confirmLabel, onPressed: onConfirm),
        AppGap.vertical(AppSpacing.sm),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(cancelLabel),
        ),
      ],
    );
  }
}

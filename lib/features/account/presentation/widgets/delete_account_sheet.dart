import 'package:flutter/material.dart';

import '../../../../config/theme/app_spacing.dart';
import '../../../../core/custom/app_sheet.dart';
import '../../../../core/custom/custom_text_field.dart';
import '../../../../core/extensions/context_extension.dart';

/// Says what deleting the account costs, asks for the password, and returns it.
///
/// Returns null if the sheet was dismissed — by the cancel line, the grabber,
/// or a tap outside it.
Future<String?> showDeleteAccountSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const DeleteAccountSheet(),
  );
}

/// A sheet with a field in it, which is why it is a widget of its own rather
/// than a call to `AppSheet.showConfirm`.
///
/// The controller is created and disposed here. It used to belong to the
/// caller, which looked tidier and was wrong: `showModalBottomSheet` completes
/// its future the moment the route pops, while the sheet stays on screen for
/// the length of the dismissal animation. Disposing the controller when the
/// future returned left the field it was still driving holding a dead object,
/// and the app threw on the next frame. Owning it here ties its life to the
/// widget that uses it, which is the only place that can get the timing right.
class DeleteAccountSheet extends StatefulWidget {
  const DeleteAccountSheet({super.key});

  @override
  State<DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<DeleteAccountSheet> {
  late final TextEditingController _passwordController;

  @override
  void initState() {
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      title: context.l10n.deleteAccountTitle,
      message: context.l10n.deleteAccountBody,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(context.l10n.deleteAccountPasswordPrompt, style: context.styles.paragraph),
          AppGap.vertical(AppSpacing.md),
          CustomTextField(
            text: context.l10n.authPassword,
            hintText: "******",
            controller: _passwordController,
            isObsecure: true,
            hasError: false,
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          AppGap.vertical(AppSpacing.lg),
          AppSheetActions(
            confirmLabel: context.l10n.deleteAccountConfirm,
            cancelLabel: context.l10n.cancel,
            isDestructive: true,
            onConfirm: _submit,
          ),
        ],
      ),
    );
  }

  /// An empty field keeps the sheet open rather than closing on a deletion
  /// that was never going to happen.
  void _submit() {
    final password = _passwordController.text;
    if (password.isEmpty) return;

    Navigator.of(context).pop(password);
  }
}

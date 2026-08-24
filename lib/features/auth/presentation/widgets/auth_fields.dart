import 'package:flutter/material.dart';

import '../../../../core/custom/custom_text_field.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/utils/validators.dart';

/// The e-mail field, with the keyboard, autofill hint and validation that go
/// with it. Both screens use this rather than each spelling out the same six
/// arguments.
class AuthEmailField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmitted;
  final String hintText;

  const AuthEmailField({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      hintText: hintText,
      controller: controller,
      text: context.l10n.authEmail,
      hasError: false,
      isObsecure: false,
      prefixIcon: Icons.alternate_email_rounded,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      validator: (value) => Validators.email(value, context.l10n),
      onSubmitted: (_) => onSubmitted(),
    );
  }
}

/// A password field. `autofillHint` is the caller's call: a login field offers
/// the saved password, a register field offers to generate a new one.
class AuthPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String autofillHint;
  final TextInputAction textInputAction;
  final String? Function(String?) validator;
  final VoidCallback onSubmitted;
  final FocusNode? focusNode;
  final String hintText;

  const AuthPasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.autofillHint,
    required this.textInputAction,
    required this.validator,
    required this.onSubmitted,
    required this.hintText,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      hintText: hintText,
      controller: controller,
      text: label,
      hasError: false,
      isObsecure: true,
      focusNode: focusNode,
      prefixIcon: Icons.lock_outline_rounded,
      textInputAction: textInputAction,
      autofillHints: [autofillHint],
      validator: validator,
      onSubmitted: (_) => onSubmitted(),
    );
  }
}

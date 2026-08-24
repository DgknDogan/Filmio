import 'package:flutter/material.dart';

import '../../config/theme/app_spacing.dart';
import '../extensions/context_extension.dart';

/// A text field with its name set above it.
///
/// The label is a separate line rather than a placeholder or a floating
/// label: it is still there once the field has content, and it does not move.
/// Everything visual — fill, hairline edge, focus colour, padding — comes from
/// `inputDecorationTheme`, so this widget only decides what the field *is*.
class CustomTextField extends StatefulWidget {
  /// The field's name, drawn above it.
  final String text;
  final String hintText;

  final bool isObsecure;
  final TextEditingController controller;

  /// Draws the field in its error colours without a message of its own — for
  /// callers that report the problem somewhere else.
  final bool hasError;

  final IconData? prefixIcon;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final int? maxLength;

  const CustomTextField({
    super.key,
    required this.text,
    required this.isObsecure,
    required this.controller,
    required this.hasError,
    required this.hintText,
    this.prefixIcon,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.maxLength,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  /// Only ever true for an obscured field. Local to the widget: it is how the
  /// field looks, not something the screen's state has an opinion about.
  bool _isRevealed = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final fields = context.theme.inputDecorationTheme;
    final isHidden = widget.isObsecure && !_isRevealed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.text.toUpperCase(), style: context.styles.fieldLabel),
        AppGap.vertical(AppSpacing.sm),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: isHidden,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          style: context.styles.inputText,
          cursorColor: palette.cursor,
          // The counter is noise on a name field; the limit still applies.
          buildCounter: (context, {required currentLength, required isFocused, required maxLength}) => null,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon == null
                ? null
                : Padding(
                    padding: EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.sm),
                    child: Icon(widget.prefixIcon, size: AppSpacing.lg),
                  ),
            suffixIcon: widget.isObsecure ? _RevealButton(isRevealed: _isRevealed, onPressed: _toggleReveal) : null,
            // A caller-driven error has no message, so only the edge changes.
            enabledBorder: widget.hasError ? fields.errorBorder : null,
            focusedBorder: widget.hasError ? fields.focusedErrorBorder : null,
          ),
        ),
      ],
    );
  }

  void _toggleReveal() => setState(() => _isRevealed = !_isRevealed);
}

/// The eye at the end of a password field.
class _RevealButton extends StatelessWidget {
  final bool isRevealed;
  final VoidCallback onPressed;

  const _RevealButton({required this.isRevealed, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final label = isRevealed ? context.l10n.authHidePassword : context.l10n.authShowPassword;

    return IconButton(
      onPressed: onPressed,
      tooltip: label,
      icon: Icon(isRevealed ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: AppSpacing.lg),
    );
  }
}

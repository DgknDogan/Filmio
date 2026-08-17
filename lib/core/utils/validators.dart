import '../../config/l10n/app_localizations.dart';

/// Field-level rules, kept out of the widgets so both auth screens reject the
/// same input for the same reason — and so the message comes from the ARB file
/// rather than from a string typed at the call site.
abstract final class Validators {
  /// Deliberately loose: enough to catch a missing `@` or a trailing space,
  /// not an attempt to out-guess the mail server.
  static final _email = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  /// Firebase's own floor, so a password can never be rejected by the server
  /// for a reason the form could have shown first.
  static const _minPasswordLength = 6;

  static String? email(String? value, AppLocalizations l10n) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return l10n.authEmailRequired;
    if (!_email.hasMatch(input)) return l10n.authEmailInvalid;
    return null;
  }

  static String? password(String? value, AppLocalizations l10n) {
    final input = value ?? '';
    if (input.isEmpty) return l10n.authPasswordRequired;
    if (input.length < _minPasswordLength) return l10n.authPasswordTooShort;
    return null;
  }

  /// The second password field on the register screen. It only has to match —
  /// the first field already reported anything else.
  static String? passwordConfirmation(String? value, String password, AppLocalizations l10n) {
    if (value != password) return l10n.authPasswordMismatch;
    return null;
  }
}

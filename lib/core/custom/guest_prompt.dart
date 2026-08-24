import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/routes/app_router.gr.dart';
import '../cubit/session_cubit.dart';
import 'app_sheet.dart';
import '../extensions/context_extension.dart';

/// Asks a guest whether they would like an account, and takes them to the
/// sign-in screen if so.
///
/// One function rather than a widget per screen: the heart on a film, the
/// heart on a series and the account tab all ask the same question, and the
/// answer always ends in the same two places.
///
/// Leaving for the sign-in screen ends the guest session first, so a half
/// finished sign-up cannot leave somebody counted as both. It also replaces
/// the stack rather than pushing: what follows is the whole auth flow —
/// register, then profile setup — and that flow owns the way back in.
Future<void> showGuestPrompt(BuildContext context, {required String title, required String body}) async {
  final router = context.router;
  final session = context.read<SessionCubit>();

  final wantsAccount = await AppSheet.showConfirm(
    context,
    title: title,
    message: body,
    confirmLabel: context.l10n.guestCreateAccount,
    cancelLabel: context.l10n.guestNotNow,
  );

  if (wantsAccount != true) return;

  await session.endGuestSession();
  await router.replaceAll([const LoginRoute()]);
}

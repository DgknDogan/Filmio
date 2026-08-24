import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/app_router.gr.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/custom/custom_button.dart';
import '../../../../core/cubit/session_cubit.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/utils/validators.dart';
import '../../../../injection_container.dart';
import '../cubit/login_cubit.dart';
import '../widgets/auth_error_snack_bar.dart';
import '../widgets/auth_fields.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_layout.dart';

@RoutePage()
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginCubit>(
      create: (context) => getIt<LoginCubit>(),
      child: BlocListener<LoginCubit, LoginState>(
        listenWhen: (previous, current) => current.errorMessage != null && previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(authErrorSnackBar(context, state.errorMessage!));
        },
        child: const _LoginView(),
      ),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final FocusNode _passwordFocus;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _passwordFocus = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: context.l10n.authLoginTitle,
      subtitle: context.l10n.authLoginSubtitle,
      form: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthEmailField(
                hintText: "example@gmail.com",
                controller: _emailController,
                onSubmitted: _passwordFocus.requestFocus,
              ),
              AppGap.vertical(AppSpacing.md),
              AuthPasswordField(
                hintText: "******",
                controller: _passwordController,
                focusNode: _passwordFocus,
                label: context.l10n.authPassword,
                autofillHint: AutofillHints.password,
                textInputAction: TextInputAction.done,
                validator: (value) => Validators.password(value, context.l10n),
                onSubmitted: _submit,
              ),
              AppGap.vertical(AppSpacing.lg),
              const _RememberMe(),
            ],
          ),
        ),
      ),
      submitButton: _SubmitButton(onPressed: _submit),
      footer: Column(
        spacing: AppSpacing.sm,
        mainAxisSize: MainAxisSize.min,
        children: [
          AuthFooter(
            prompt: context.l10n.authNoAccount,
            action: context.l10n.authSignUp,
            onPressed: () => context.router.push(const RegisterRoute()),
          ),
          // Quieter than either of the two above it: an account is still the
          // way most people should arrive, and this is the door for everyone
          // who wants to see what the app is first.
          TextButton(
            onPressed: _continueAsGuest,
            child: Text(context.l10n.authContinueAsGuest, style: context.styles.footerPrompt),
          ),
        ],
      ),
    );
  }

  /// Into the app with no account at all. Nothing is created anywhere — the
  /// whole session is a flag on this device, which is why there is nothing to
  /// undo but a sign-in.
  Future<void> _continueAsGuest() async {
    final router = context.router;

    await context.read<SessionCubit>().startGuestSession();

    FocusManager.instance.primaryFocus?.unfocus();
    await router.replace(const WrapperRoute());
  }

  Future<void> _submit() async {
    // The form answers what the server should never be asked twice.
    if (!_formKey.currentState!.validate()) return;

    final router = context.router;
    final session = context.read<SessionCubit>();
    final outcome = await context.read<LoginCubit>().login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    // A failure is already on screen via the page's BlocListener.
    if (outcome == LoginOutcome.failed) return;

    // Signing in ends any guest session; the cubit above the router has to be
    // told, or the account tab greets a signed-in user as "Guest".
    await session.refresh();

    FocusManager.instance.primaryFocus?.unfocus();
    router.replace(outcome == LoginOutcome.needsProfile ? const SetProfileRoute() : const WrapperRoute());
  }
}

/// The checkbox and its label, as one target. Tapping the words works too,
/// which is the difference between a 24pt hit area and a comfortable one.
class _RememberMe extends StatelessWidget {
  const _RememberMe();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<LoginCubit, LoginState, bool>(
      selector: (state) => state.isChecked,
      builder: (context, isChecked) {
        return Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            // borderRadius: AppRadius.smAll,
            onTap: () => context.read<LoginCubit>().changeCheckBox(!isChecked),
            child: Row(
              spacing: AppSpacing.md,
              mainAxisSize: MainAxisSize.min,
              children: [
                // The row owns the gesture, so the box only has to draw.
                Checkbox(
                  value: isChecked,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                  onChanged: (_) => context.read<LoginCubit>().changeCheckBox(!isChecked),
                ),
                Text(context.l10n.authRememberMe, style: context.styles.footerPrompt),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SubmitButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<LoginCubit, LoginState, bool>(
      selector: (state) => state.isSubmitting,
      builder: (context, isSubmitting) {
        return CustomButton(
          text: context.l10n.authLogIn,
          isLoading: isSubmitting,
          onPressed: onPressed,
        );
      },
    );
  }
}

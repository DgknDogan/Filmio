import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/app_spacing.dart';
import '../../../../core/custom/custom_button.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/utils/validators.dart';
import '../../../../injection_container.dart';
import '../cubit/register_cubit.dart';
import '../widgets/auth_error_snack_bar.dart';
import '../widgets/auth_fields.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_layout.dart';

@RoutePage()
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(getIt()),
      child: BlocListener<RegisterCubit, RegisterState>(
        listenWhen: (previous, current) => current.errorMessage != null && previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(authErrorSnackBar(context, state.errorMessage!));
        },
        child: const _RegisterView(),
      ),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmationController;
  late final FocusNode _passwordFocus;
  late final FocusNode _confirmationFocus;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmationController = TextEditingController();
    _passwordFocus = FocusNode();
    _confirmationFocus = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    _passwordFocus.dispose();
    _confirmationFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: context.l10n.authRegisterTitle,
      subtitle: context.l10n.authRegisterSubtitle,
      form: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthEmailField(
                controller: _emailController,
                onSubmitted: _passwordFocus.requestFocus,
              ),
              AppGap.vertical(AppSpacing.md),
              AuthPasswordField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                label: context.l10n.authPassword,
                autofillHint: AutofillHints.newPassword,
                textInputAction: TextInputAction.next,
                validator: (value) => Validators.password(value, context.l10n),
                onSubmitted: _confirmationFocus.requestFocus,
              ),
              AppGap.vertical(AppSpacing.md),
              // Catching a typo here costs one field; catching it after the
              // account exists costs a password reset.
              AuthPasswordField(
                controller: _confirmationController,
                focusNode: _confirmationFocus,
                label: context.l10n.authConfirmPassword,
                autofillHint: AutofillHints.newPassword,
                textInputAction: TextInputAction.done,
                validator: (value) => Validators.passwordConfirmation(value, _passwordController.text, context.l10n),
                onSubmitted: _submit,
              ),
            ],
          ),
        ),
      ),
      submitButton: _SubmitButton(onPressed: _submit),
      footer: AuthFooter(
        prompt: context.l10n.authHaveAccount,
        action: context.l10n.authSignIn,
        onPressed: () => context.router.maybePop(),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final router = context.router;
    final isUserCreated = await context.read<RegisterCubit>().createAccount(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    // A failure is already on screen via the page's BlocListener.
    if (!isUserCreated) return;

    FocusManager.instance.primaryFocus?.unfocus();
    router.maybePop();
  }
}

class _SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SubmitButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<RegisterCubit, RegisterState, bool>(
      selector: (state) => state.isSubmitting,
      builder: (context, isSubmitting) {
        return CustomButton(
          text: context.l10n.authRegister,
          isLoading: isSubmitting,
          onPressed: onPressed,
        );
      },
    );
  }
}

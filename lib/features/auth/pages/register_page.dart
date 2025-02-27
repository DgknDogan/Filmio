import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/custom/custom_button.dart';
import '../../../utils/custom/custom_form.dart';
import '../cubit/register_cubit.dart';
import '../widgets/form_container.dart';

@RoutePage()
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocProvider(
        create: (context) => RegisterCubit(),
        child: SafeArea(
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/logo.png",
                    height: 200.h,
                    color: Colors.white,
                  ),
                ],
              ),
              _RegisterForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  const _RegisterForm();

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(
      builder: (context, state) {
        return Center(
          child: FormContainer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "REGISTER",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 20.h),
                CustomForm(
                  emailController: emailController,
                  passwordController: passwordController,
                ),
                SizedBox(height: 10.h),
                _FormSubTexts(),
                SizedBox(height: 30.h),
                CustomButton(
                  text: "Register",
                  width: double.infinity,
                  onPressed: () async {
                    final isUserCreated = await context.read<RegisterCubit>().createAccount(
                          email: emailController.text,
                          password: passwordController.text,
                        );
                    if (isUserCreated && context.mounted) {
                      emailController.clear();
                      passwordController.clear();
                      context.router.maybePop();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FormSubTexts extends StatelessWidget {
  const _FormSubTexts();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            context.router.maybePop();
          },
          child: Text(
            "Have an account?",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

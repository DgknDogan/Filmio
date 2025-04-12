import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/extensions/brightness_extension.dart';
import '../../../../core/utils/custom/custom_button.dart';
import '../../../../core/utils/custom/custom_clipper.dart';
import '../../../../core/utils/custom/custom_form.dart';
import '../../../../injection_container.dart';
import '../cubit/register_cubit.dart';

@RoutePage()
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocProvider(
        create: (context) => RegisterCubit(getIt()),
        child: Column(
          children: [
            _LoginHeader(),
            _RegisterForm(),
          ],
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CustomBorderClipper(),
      child: Container(
        height: 170.h,
        width: double.infinity,
        decoration: Theme.of(context).isLight
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff6a5acd),
                    Color(0xff3700b3),
                  ],
                ),
              )
            : BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff252525),
                    Colors.black,
                  ],
                ),
              ),
        child: Container(
          margin: EdgeInsets.only(left: 20.w, top: 50.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create a new",
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white, fontSize: 26.sp),
              ),
              Text(
                "Account",
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: 28.sp),
              ),
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
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
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

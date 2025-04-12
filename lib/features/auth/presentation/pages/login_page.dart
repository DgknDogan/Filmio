import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/routes/app_router.gr.dart';
import '../../../../core/extensions/brightness_extension.dart';
import '../../../../core/utils/custom/custom_button.dart';
import '../../../../core/utils/custom/custom_clipper.dart';
import '../../../../core/utils/custom/custom_form.dart';
import '../../../../injection_container.dart';
import '../cubit/login_cubit.dart';

@RoutePage()
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginCubit>(
      create: (context) => getIt<LoginCubit>(),
      child: Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            _LoginHeader(),
            _LoginForm(),
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
                "Hello, Welcome back to",
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white, fontSize: 26.sp),
              ),
              Text(
                "Filmio",
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: 28.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  final auth = FirebaseAuth.instance;

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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomForm(
            emailController: emailController,
            passwordController: passwordController,
          ),
          SizedBox(height: 10.h),
          _FormSubTexts(),
          SizedBox(height: 30.h),
          CustomButton(
            text: "Log In",
            width: double.infinity,
            onPressed: () async {
              final isLoggedin = await context.read<LoginCubit>().login(
                    email: emailController.text,
                    password: passwordController.text,
                  );
              if (context.mounted && isLoggedin && auth.currentUser!.displayName == null) {
                FocusManager.instance.primaryFocus?.unfocus();
                context.router.replace(SetProfile());
              } else if (context.mounted && isLoggedin && auth.currentUser!.displayName != null) {
                FocusManager.instance.primaryFocus?.unfocus();
                context.router.replace(HomeRoute());
              }
            },
          ),
        ],
      ),
    );
  }
}

class _FormSubTexts extends StatelessWidget {
  const _FormSubTexts();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 5.w,
              children: [
                Checkbox(
                  activeColor: Theme.of(context).isLight ? Color(0xff3700b3) : Colors.white,
                  value: state.isChecked,
                  onChanged: (value) {
                    context.read<LoginCubit>().changeCheckBox(value!);
                  },
                ),
                Text(
                  "Remember Me",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                context.router.push(RegisterRoute());
              },
              child: Text(
                "Create an account",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        );
      },
    );
  }
}

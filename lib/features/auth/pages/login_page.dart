import 'package:auto_route/auto_route.dart';
import 'package:filmio/routes/app_router.gr.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/custom/custom_button.dart';
import '../../../utils/custom/custom_form.dart';
import '../cubit/login_cubit.dart';

@RoutePage()
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: 20.h),
                Image.asset(
                  "assets/logo.png",
                  height: 200.h,
                ),
                SizedBox(height: 20.h),
                _LoginForm(),
              ],
            ),
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
      decoration: BoxDecoration(
        color: Color(0xffCCD5AE),
        borderRadius: BorderRadius.all(
          Radius.circular(20.r),
        ),
      ),
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
      child: Column(
        children: [
          Text(
            "LOGIN",
            style: TextStyle(
              color: Color(0xff283618),
              fontSize: 24.sp,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
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
            text: "Log In",
            width: double.infinity,
            onPressed: () async {
              await context.read<LoginCubit>().login(
                    email: emailController.text,
                    password: passwordController.text,
                  );
              if (context.mounted && auth.currentUser != null && auth.currentUser!.displayName == null) {
                await context.router.push(SetProfile());
              } else if (context.mounted && auth.currentUser != null && auth.currentUser!.displayName != null) {
                context.router.push(FilmHomeRoute());
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
              children: [
                Checkbox(
                  splashRadius: 0,
                  activeColor: Color(0xff283618),
                  visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: state.isChecked,
                  onChanged: (value) {
                    context.read<LoginCubit>().changeCheckBox(value!);
                  },
                ),
                SizedBox(width: 5.w),
                Text(
                  "Remember Me",
                  style: TextStyle(color: Color(0xff283618)),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                context.router.push(RegisterRoute());
              },
              child: Text(
                "Create an account",
                style: TextStyle(
                  color: Color(0xff283618),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

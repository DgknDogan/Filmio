import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/custom/custom_button.dart';
import '../../../utils/custom/custom_form.dart';
import '../cubit/register_cubit.dart';

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
                _RegisterForm(),
              ],
            ),
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
                "REGISTER",
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
                text: "Register",
                width: double.infinity,
                onPressed: () async {
                  await context.read<RegisterCubit>().createAccount(
                        email: emailController.text,
                        password: passwordController.text,
                      );
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
            style: TextStyle(color: Color(0xff283618)),
          ),
        ),
      ],
    );
  }
}

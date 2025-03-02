import 'package:auto_route/auto_route.dart';
import 'package:filmio/config/routes/app_router.gr.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../injection_container.dart';
import '../../../utils/custom/custom_button.dart';
import '../../../utils/custom/custom_form.dart';
import '../cubit/login_cubit.dart';
import '../widgets/form_container.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final String? _cachedEmail;
  late final String? _cachedPassword;
  @override
  void initState() {
    final cubit = getIt<LoginCubit>();
    _cachedEmail = getIt<SharedPreferences>().getString("email");
    _cachedPassword = getIt<SharedPreferences>().getString("password");
    cubit.isAccountRemembered(email: _cachedEmail, password: _cachedPassword);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginCubit>(
      create: (context) => getIt<LoginCubit>(),
      child: BlocListener<LoginCubit, LoginState>(
        listenWhen: (previous, current) {
          return previous.isRemembered != current.isRemembered;
        },
        listener: (context, state) async {
          if (state.isRemembered) {
            final isLoggedIn = await context.read<LoginCubit>().login(email: _cachedEmail!, password: _cachedPassword!);
            if (context.mounted && isLoggedIn) {
              context.router.push(SplashRoute());
            }
          }
        },
        child: Scaffold(
          body: SafeArea(
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
    return Center(
      child: FormContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "LOGIN",
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
              text: "Log In",
              width: double.infinity,
              onPressed: () async {
                final isLoggedin = await context.read<LoginCubit>().login(
                      email: emailController.text,
                      password: passwordController.text,
                    );
                if (context.mounted && isLoggedin && auth.currentUser!.displayName == null) {
                  context.router.push(SetProfile());
                } else if (context.mounted && isLoggedin && auth.currentUser!.displayName != null) {
                  context.router.push(SplashRoute());
                }
                if (isLoggedin) {
                  emailController.clear();
                  passwordController.clear();
                }
              },
            ),
          ],
        ),
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
                  activeColor: Color(0xff1a1a1a),
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

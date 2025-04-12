import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/routes/app_router.gr.dart';
import '../../../core/extensions/brightness_extension.dart';
import '../../../injection_container.dart';
import '../../auth/presentation/cubit/login_cubit.dart';

@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _firstAnimaitonController;
  final List<Effect> _firstAnimation = [
    FadeEffect(
      begin: 0,
      end: 1,
      duration: 2000.ms,
      curve: Curves.easeOut,
    ),
    MoveEffect(
      begin: Offset(0, -200.h),
      end: Offset(0, 0),
      duration: 2000.ms,
      curve: Curves.easeOut,
    )
  ];
  late final String? _cachedEmail;
  late final String? _cachedPassword;

  @override
  void initState() {
    _firstAnimaitonController = AnimationController(
      vsync: this,
      duration: 2000.ms,
    )..forward();
    _cachedEmail = getIt<SharedPreferences>().getString("email");
    _cachedPassword = getIt<SharedPreferences>().getString("password");
    getIt<LoginCubit>().isAccountRemembered(email: _cachedEmail, password: _cachedPassword);
    super.initState();
  }

  @override
  void dispose() async {
    _firstAnimaitonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => getIt<LoginCubit>(),
        child: Center(
          child: Image.asset(
            "assets/logo.png",
            height: 250.h,
            color: Theme.of(context).isLight ? Colors.black : Colors.white,
          ).animate(
            controller: _firstAnimaitonController,
            effects: _firstAnimation,
            onComplete: (controller) {
              Future.delayed(
                1.seconds,
                () async {
                  if (context.mounted) {
                    final isLoggedin = await getIt<LoginCubit>().login(email: _cachedEmail ?? "", password: _cachedPassword ?? "");

                    if (isLoggedin && context.mounted) {
                      context.router.replace(HomeRoute());
                    } else if (!isLoggedin && context.mounted) {
                      context.router.replace(LoginRoute());
                    }
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

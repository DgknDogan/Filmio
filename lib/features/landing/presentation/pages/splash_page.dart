import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/routes/app_router.gr.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../injection_container.dart';
import '../cubit/splash_cubit.dart';
import '../../../../gen/assets.gen.dart';

@RoutePage()
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SplashCubit>(),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatefulWidget {
  const _SplashView();

  @override
  State<_SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<_SplashView> with SingleTickerProviderStateMixin {
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
      end: const Offset(0, 0),
      duration: 2000.ms,
      curve: Curves.easeOut,
    )
  ];

  @override
  void initState() {
    _firstAnimaitonController = AnimationController(
      vsync: this,
      duration: 2000.ms,
    )..forward();
    super.initState();
  }

  @override
  void dispose() {
    _firstAnimaitonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          switch (state) {
            case SplashChecking():
              break;
            case SplashAuthenticated():
              context.router.replace(const WrapperRoute());
            case SplashUnauthenticated():
              context.router.replace(const LoginRoute());
          }
        },
        child: Center(
          child: Assets.logo
              .image(
                height: 250.h,
                color: context.palette.textPrimary,
              )
              .animate(
                controller: _firstAnimaitonController,
                effects: _firstAnimation,
                onComplete: (controller) {
                  // Resolve the cubit before the delay so nothing reaches across
                  // the async gap for a BuildContext; the cubit guards isClosed.
                  final splashCubit = context.read<SplashCubit>();
                  Future.delayed(1.seconds, splashCubit.resolveDestination);
                },
              ),
        ),
      ),
    );
  }
}

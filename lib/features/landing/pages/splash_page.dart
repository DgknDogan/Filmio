import 'package:auto_route/auto_route.dart';
import 'package:filmio/config/routes/app_router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      begin: Offset(0, 0),
      end: Offset(0, 200.h),
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
    return Builder(
      builder: (context) {
        return Scaffold(
          body: Column(
            children: [
              Center(
                child: Image.asset(
                  "assets/logo.png",
                  height: 250.h,
                  color: Colors.white,
                ).animate(
                  controller: _firstAnimaitonController,
                  effects: _firstAnimation,
                  onComplete: (controller) {
                    Future.delayed(
                      1.seconds,
                      () {
                        if (context.mounted) {
                          context.router.replace(
                            HomeRoute(),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

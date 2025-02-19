import 'package:auto_route/auto_route.dart';
import 'package:filmio/routes/app_router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../account/cubit/account_cubit.dart';
import '../../film/cubit/film_home_page_cubit.dart';
import '../../series/cubit/series_home_page_cubit.dart';

@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
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
      duration: 3000.ms,
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
    return MultiBlocProvider(
      providers: [
        BlocProvider<FilmHomePageCubit>(create: (context) => FilmHomePageCubit()),
        BlocProvider<SeriesHomePageCubit>(create: (context) => SeriesHomePageCubit()),
        BlocProvider<AccountCubit>(create: (context) => AccountCubit()),
      ],
      child: Builder(builder: (context) {
        final filmHomePageCubit = context.read<FilmHomePageCubit>();
        final seriesHomePageCubit = context.read<SeriesHomePageCubit>();
        final accountCubit = context.read<AccountCubit>();

        return Scaffold(
          body: Column(
            children: [
              Center(
                child: Image.asset("assets/logo.png", height: 250.h).animate(
                  controller: _firstAnimaitonController,
                  effects: _firstAnimation,
                  onComplete: (controller) {
                    Future.delayed(
                      1.seconds,
                      () {
                        if (context.mounted) {
                          context.router.push(
                            HomeRoute(
                              accountCubit: accountCubit,
                              filmHomePageCubit: filmHomePageCubit,
                              seriesHomePageCubit: seriesHomePageCubit,
                            ),
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
      }),
    );
  }
}

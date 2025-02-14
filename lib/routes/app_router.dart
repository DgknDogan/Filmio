import 'package:auto_route/auto_route.dart';
import 'package:filmio/routes/app_router.gr.dart';
import 'package:flutter/material.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: LoginRoute.page,
        ),
        AutoRoute(
          page: RegisterRoute.page,
        ),
        AutoRoute(
          page: SetProfile.page,
        ),
        CustomRoute(
          page: FilmHomeRoute.page,
          initial: true,
        ),
        CustomRoute(
          page: FilmDetailsRoute.page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ];
}

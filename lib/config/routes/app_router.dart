import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: LoginRoute.page,
          initial: true,
        ),
        AutoRoute(
          page: RegisterRoute.page,
        ),
        AutoRoute(
          page: SetProfile.page,
        ),
        CustomRoute(
          page: SplashRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
        ),
        CustomRoute(
          page: HomeRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          children: [
            CustomRoute(
              page: MovieRoute.page,
              transitionsBuilder: TransitionsBuilders.fadeIn,
              initial: true,
            ),
            CustomRoute(
              page: SeriesHomeRoute.page,
              transitionsBuilder: TransitionsBuilders.fadeIn,
            ),
            CustomRoute(
              page: AccountRoute.page,
              transitionsBuilder: TransitionsBuilders.fadeIn,
            )
          ],
        ),
        CustomRoute(
          page: MovieDetailsRoute.page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
        CustomRoute(
          page: SeriesDeatailsRoute.page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ];
}

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: SplashRoute.page,
          initial: true,
        ),
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
          transitionsBuilder: (context, animation, secondaryAnimation, child) => slideLeftTransition(context, animation, secondaryAnimation, child),
          durationInMilliseconds: 1000,
          page: HomeRoute.page,
          children: [
            AutoRoute(
              page: MovieRoute.page,
              initial: true,
            ),
            AutoRoute(
              page: SeriesHomeRoute.page,
            ),
            AutoRoute(
              page: AccountRoute.page,
            ),
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
        AutoRoute(
          page: LikedMoviesRoute.page,
        ),
        CustomRoute(
          page: MovieSearchRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
        ),
        CustomRoute(
          page: SeriesSearchRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
        ),
        CustomRoute(
          page: SettingsRoute.page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) => slideLeftTransition(context, animation, secondaryAnimation, child),
        )
      ];
}

SlideTransition slideLeftTransition(context, animation, secondaryAnimation, child) {
  final curve = CurvedAnimation(
    parent: animation,
    curve: Curves.easeInOutCubic,
  );
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(curve),
    child: child,
  );
}

import 'package:auto_route/auto_route.dart';
import 'package:filmio/routes/app_router.gr.dart';

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
          page: FilmHomeRoute.page,
        ),
        AutoRoute(
          page: SetProfile.page,
        )
      ];
}

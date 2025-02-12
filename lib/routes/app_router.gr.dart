// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i5;
import 'package:filmio/features/auth/pages/login_page.dart' as _i2;
import 'package:filmio/features/auth/pages/register_page.dart' as _i3;
import 'package:filmio/features/auth/pages/set_profile_page.dart' as _i4;
import 'package:filmio/features/film/pages/film_home_page.dart' as _i1;

/// generated route for
/// [_i1.FilmHomePage]
class FilmHomeRoute extends _i5.PageRouteInfo<void> {
  const FilmHomeRoute({List<_i5.PageRouteInfo>? children})
    : super(FilmHomeRoute.name, initialChildren: children);

  static const String name = 'FilmHomeRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i1.FilmHomePage();
    },
  );
}

/// generated route for
/// [_i2.LoginPage]
class LoginRoute extends _i5.PageRouteInfo<void> {
  const LoginRoute({List<_i5.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i2.LoginPage();
    },
  );
}

/// generated route for
/// [_i3.RegisterPage]
class RegisterRoute extends _i5.PageRouteInfo<void> {
  const RegisterRoute({List<_i5.PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i3.RegisterPage();
    },
  );
}

/// generated route for
/// [_i4.SetProfile]
class SetProfile extends _i5.PageRouteInfo<void> {
  const SetProfile({List<_i5.PageRouteInfo>? children})
    : super(SetProfile.name, initialChildren: children);

  static const String name = 'SetProfile';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i4.SetProfile();
    },
  );
}

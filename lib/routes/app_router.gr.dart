// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i10;
import 'package:filmio/features/auth/pages/login_page.dart' as _i5;
import 'package:filmio/features/auth/pages/register_page.dart' as _i6;
import 'package:filmio/features/auth/pages/set_profile_page.dart' as _i8;
import 'package:filmio/features/home/account/pages/account_page.dart' as _i1;
import 'package:filmio/features/home/film/models/film_model.dart' as _i12;
import 'package:filmio/features/home/film/pages/film_details_page.dart' as _i2;
import 'package:filmio/features/home/film/pages/film_home_page.dart' as _i3;
import 'package:filmio/features/home/pages/home_page.dart' as _i4;
import 'package:filmio/features/home/pages/splash_page.dart' as _i9;
import 'package:filmio/features/home/series/pages/series_home_page.dart' as _i7;
import 'package:flutter/material.dart' as _i11;

/// generated route for
/// [_i1.AccountPage]
class AccountRoute extends _i10.PageRouteInfo<void> {
  const AccountRoute({List<_i10.PageRouteInfo>? children})
    : super(AccountRoute.name, initialChildren: children);

  static const String name = 'AccountRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i1.AccountPage();
    },
  );
}

/// generated route for
/// [_i2.FilmDetailsPage]
class FilmDetailsRoute extends _i10.PageRouteInfo<FilmDetailsRouteArgs> {
  FilmDetailsRoute({
    _i11.Key? key,
    required _i12.FilmModel film,
    required String heroTag,
    List<_i10.PageRouteInfo>? children,
  }) : super(
         FilmDetailsRoute.name,
         args: FilmDetailsRouteArgs(key: key, film: film, heroTag: heroTag),
         initialChildren: children,
       );

  static const String name = 'FilmDetailsRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FilmDetailsRouteArgs>();
      return _i2.FilmDetailsPage(
        key: args.key,
        film: args.film,
        heroTag: args.heroTag,
      );
    },
  );
}

class FilmDetailsRouteArgs {
  const FilmDetailsRouteArgs({
    this.key,
    required this.film,
    required this.heroTag,
  });

  final _i11.Key? key;

  final _i12.FilmModel film;

  final String heroTag;

  @override
  String toString() {
    return 'FilmDetailsRouteArgs{key: $key, film: $film, heroTag: $heroTag}';
  }
}

/// generated route for
/// [_i3.FilmHomePage]
class FilmHomeRoute extends _i10.PageRouteInfo<void> {
  const FilmHomeRoute({List<_i10.PageRouteInfo>? children})
    : super(FilmHomeRoute.name, initialChildren: children);

  static const String name = 'FilmHomeRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i3.FilmHomePage();
    },
  );
}

/// generated route for
/// [_i4.HomePage]
class HomeRoute extends _i10.PageRouteInfo<void> {
  const HomeRoute({List<_i10.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i4.HomePage();
    },
  );
}

/// generated route for
/// [_i5.LoginPage]
class LoginRoute extends _i10.PageRouteInfo<void> {
  const LoginRoute({List<_i10.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i5.LoginPage();
    },
  );
}

/// generated route for
/// [_i6.RegisterPage]
class RegisterRoute extends _i10.PageRouteInfo<void> {
  const RegisterRoute({List<_i10.PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i6.RegisterPage();
    },
  );
}

/// generated route for
/// [_i7.SeriesHomePage]
class SeriesHomeRoute extends _i10.PageRouteInfo<void> {
  const SeriesHomeRoute({List<_i10.PageRouteInfo>? children})
    : super(SeriesHomeRoute.name, initialChildren: children);

  static const String name = 'SeriesHomeRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i7.SeriesHomePage();
    },
  );
}

/// generated route for
/// [_i8.SetProfile]
class SetProfile extends _i10.PageRouteInfo<void> {
  const SetProfile({List<_i10.PageRouteInfo>? children})
    : super(SetProfile.name, initialChildren: children);

  static const String name = 'SetProfile';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i8.SetProfile();
    },
  );
}

/// generated route for
/// [_i9.SplashPage]
class SplashRoute extends _i10.PageRouteInfo<void> {
  const SplashRoute({List<_i10.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i9.SplashPage();
    },
  );
}

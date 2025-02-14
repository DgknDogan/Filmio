// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i6;
import 'package:filmio/features/auth/pages/login_page.dart' as _i3;
import 'package:filmio/features/auth/pages/register_page.dart' as _i4;
import 'package:filmio/features/auth/pages/set_profile_page.dart' as _i5;
import 'package:filmio/features/film/models/film_model.dart' as _i8;
import 'package:filmio/features/film/pages/film_details_page.dart' as _i1;
import 'package:filmio/features/film/pages/film_home_page.dart' as _i2;
import 'package:flutter/material.dart' as _i7;

/// generated route for
/// [_i1.FilmDetailsPage]
class FilmDetailsRoute extends _i6.PageRouteInfo<FilmDetailsRouteArgs> {
  FilmDetailsRoute({
    _i7.Key? key,
    required _i8.FilmModel film,
    required String heroTag,
    List<_i6.PageRouteInfo>? children,
  }) : super(
         FilmDetailsRoute.name,
         args: FilmDetailsRouteArgs(key: key, film: film, heroTag: heroTag),
         initialChildren: children,
       );

  static const String name = 'FilmDetailsRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FilmDetailsRouteArgs>();
      return _i1.FilmDetailsPage(
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

  final _i7.Key? key;

  final _i8.FilmModel film;

  final String heroTag;

  @override
  String toString() {
    return 'FilmDetailsRouteArgs{key: $key, film: $film, heroTag: $heroTag}';
  }
}

/// generated route for
/// [_i2.FilmHomePage]
class FilmHomeRoute extends _i6.PageRouteInfo<void> {
  const FilmHomeRoute({List<_i6.PageRouteInfo>? children})
    : super(FilmHomeRoute.name, initialChildren: children);

  static const String name = 'FilmHomeRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i2.FilmHomePage();
    },
  );
}

/// generated route for
/// [_i3.LoginPage]
class LoginRoute extends _i6.PageRouteInfo<void> {
  const LoginRoute({List<_i6.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i3.LoginPage();
    },
  );
}

/// generated route for
/// [_i4.RegisterPage]
class RegisterRoute extends _i6.PageRouteInfo<void> {
  const RegisterRoute({List<_i6.PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i4.RegisterPage();
    },
  );
}

/// generated route for
/// [_i5.SetProfile]
class SetProfile extends _i6.PageRouteInfo<void> {
  const SetProfile({List<_i6.PageRouteInfo>? children})
    : super(SetProfile.name, initialChildren: children);

  static const String name = 'SetProfile';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i5.SetProfile();
    },
  );
}

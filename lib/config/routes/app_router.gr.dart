// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i12;
import 'package:filmio/features/account/presentation/pages/account_page.dart'
    as _i1;
import 'package:filmio/features/account/presentation/pages/liked_movies_page.dart'
    as _i3;
import 'package:filmio/features/auth/presentation/pages/login_page.dart' as _i4;
import 'package:filmio/features/auth/presentation/pages/register_page.dart'
    as _i7;
import 'package:filmio/features/auth/presentation/pages/set_profile_page.dart'
    as _i10;
import 'package:filmio/features/landing/pages/home_page.dart' as _i2;
import 'package:filmio/features/landing/pages/splash_page.dart' as _i11;
import 'package:filmio/features/movie/domain/entities/movie.dart' as _i14;
import 'package:filmio/features/movie/presentation/pages/movie_details_page.dart'
    as _i5;
import 'package:filmio/features/movie/presentation/pages/movie_page.dart'
    as _i6;
import 'package:filmio/features/series/domain/entities/series_entity.dart'
    as _i15;
import 'package:filmio/features/series/presentation/pages/series_deatails_page.dart'
    as _i8;
import 'package:filmio/features/series/presentation/pages/series_page.dart'
    as _i9;
import 'package:flutter/material.dart' as _i13;

/// generated route for
/// [_i1.AccountPage]
class AccountRoute extends _i12.PageRouteInfo<void> {
  const AccountRoute({List<_i12.PageRouteInfo>? children})
    : super(AccountRoute.name, initialChildren: children);

  static const String name = 'AccountRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i1.AccountPage();
    },
  );
}

/// generated route for
/// [_i2.HomePage]
class HomeRoute extends _i12.PageRouteInfo<void> {
  const HomeRoute({List<_i12.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i2.HomePage();
    },
  );
}

/// generated route for
/// [_i3.LikedMoviesPage]
class LikedMoviesRoute extends _i12.PageRouteInfo<void> {
  const LikedMoviesRoute({List<_i12.PageRouteInfo>? children})
    : super(LikedMoviesRoute.name, initialChildren: children);

  static const String name = 'LikedMoviesRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i3.LikedMoviesPage();
    },
  );
}

/// generated route for
/// [_i4.LoginPage]
class LoginRoute extends _i12.PageRouteInfo<void> {
  const LoginRoute({List<_i12.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i4.LoginPage();
    },
  );
}

/// generated route for
/// [_i5.MovieDetailsPage]
class MovieDetailsRoute extends _i12.PageRouteInfo<MovieDetailsRouteArgs> {
  MovieDetailsRoute({
    _i13.Key? key,
    required _i14.MovieEntity movie,
    required String heroTag,
    List<_i12.PageRouteInfo>? children,
  }) : super(
         MovieDetailsRoute.name,
         args: MovieDetailsRouteArgs(key: key, movie: movie, heroTag: heroTag),
         initialChildren: children,
       );

  static const String name = 'MovieDetailsRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MovieDetailsRouteArgs>();
      return _i5.MovieDetailsPage(
        key: args.key,
        movie: args.movie,
        heroTag: args.heroTag,
      );
    },
  );
}

class MovieDetailsRouteArgs {
  const MovieDetailsRouteArgs({
    this.key,
    required this.movie,
    required this.heroTag,
  });

  final _i13.Key? key;

  final _i14.MovieEntity movie;

  final String heroTag;

  @override
  String toString() {
    return 'MovieDetailsRouteArgs{key: $key, movie: $movie, heroTag: $heroTag}';
  }
}

/// generated route for
/// [_i6.MoviePage]
class MovieRoute extends _i12.PageRouteInfo<void> {
  const MovieRoute({List<_i12.PageRouteInfo>? children})
    : super(MovieRoute.name, initialChildren: children);

  static const String name = 'MovieRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i6.MoviePage();
    },
  );
}

/// generated route for
/// [_i7.RegisterPage]
class RegisterRoute extends _i12.PageRouteInfo<void> {
  const RegisterRoute({List<_i12.PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i7.RegisterPage();
    },
  );
}

/// generated route for
/// [_i8.SeriesDeatailsPage]
class SeriesDeatailsRoute extends _i12.PageRouteInfo<SeriesDeatailsRouteArgs> {
  SeriesDeatailsRoute({
    _i13.Key? key,
    required _i15.SeriesEntity series,
    required String heroTag,
    List<_i12.PageRouteInfo>? children,
  }) : super(
         SeriesDeatailsRoute.name,
         args: SeriesDeatailsRouteArgs(
           key: key,
           series: series,
           heroTag: heroTag,
         ),
         initialChildren: children,
       );

  static const String name = 'SeriesDeatailsRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SeriesDeatailsRouteArgs>();
      return _i8.SeriesDeatailsPage(
        key: args.key,
        series: args.series,
        heroTag: args.heroTag,
      );
    },
  );
}

class SeriesDeatailsRouteArgs {
  const SeriesDeatailsRouteArgs({
    this.key,
    required this.series,
    required this.heroTag,
  });

  final _i13.Key? key;

  final _i15.SeriesEntity series;

  final String heroTag;

  @override
  String toString() {
    return 'SeriesDeatailsRouteArgs{key: $key, series: $series, heroTag: $heroTag}';
  }
}

/// generated route for
/// [_i9.SeriesHomePage]
class SeriesHomeRoute extends _i12.PageRouteInfo<void> {
  const SeriesHomeRoute({List<_i12.PageRouteInfo>? children})
    : super(SeriesHomeRoute.name, initialChildren: children);

  static const String name = 'SeriesHomeRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i9.SeriesHomePage();
    },
  );
}

/// generated route for
/// [_i10.SetProfile]
class SetProfile extends _i12.PageRouteInfo<void> {
  const SetProfile({List<_i12.PageRouteInfo>? children})
    : super(SetProfile.name, initialChildren: children);

  static const String name = 'SetProfile';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i10.SetProfile();
    },
  );
}

/// generated route for
/// [_i11.SplashPage]
class SplashRoute extends _i12.PageRouteInfo<void> {
  const SplashRoute({List<_i12.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i11.SplashPage();
    },
  );
}

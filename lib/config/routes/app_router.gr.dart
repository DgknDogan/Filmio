// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i19;
import 'package:filmio/core/enums/discover_sort.dart' as _i22;
import 'package:filmio/features/account/presentation/pages/account_page.dart' as _i1;
import 'package:filmio/features/account/presentation/pages/liked_movies_page.dart' as _i2;
import 'package:filmio/features/account/presentation/pages/liked_series_page.dart' as _i3;
import 'package:filmio/features/account/presentation/pages/settings_page.dart' as _i15;
import 'package:filmio/features/auth/presentation/pages/login_page.dart' as _i4;
import 'package:filmio/features/auth/presentation/pages/register_page.dart' as _i9;
import 'package:filmio/features/auth/presentation/pages/set_profile_page.dart' as _i14;
import 'package:filmio/features/landing/presentation/pages/splash_page.dart' as _i16;
import 'package:filmio/features/landing/presentation/pages/wrapper_page.dart' as _i18;
import 'package:filmio/features/movie/domain/entities/movie.dart' as _i21;
import 'package:filmio/features/movie/presentation/pages/movie_details_page.dart' as _i5;
import 'package:filmio/features/movie/presentation/pages/movie_discover_page.dart' as _i6;
import 'package:filmio/features/movie/presentation/pages/movie_page.dart' as _i7;
import 'package:filmio/features/movie/presentation/pages/movie_search_page.dart' as _i8;
import 'package:filmio/features/series/domain/entities/series_entity.dart' as _i23;
import 'package:filmio/features/series/presentation/pages/series_details_page.dart' as _i10;
import 'package:filmio/features/series/presentation/pages/series_discover_page.dart' as _i11;
import 'package:filmio/features/series/presentation/pages/series_page.dart' as _i12;
import 'package:filmio/features/series/presentation/pages/series_search_page.dart' as _i13;
import 'package:filmio/features/video/domain/entities/video_entity.dart' as _i24;
import 'package:filmio/features/video/presentation/pages/trailer_page.dart' as _i17;
import 'package:flutter/material.dart' as _i20;

/// generated route for
/// [_i1.AccountPage]
class AccountRoute extends _i19.PageRouteInfo<void> {
  const AccountRoute({List<_i19.PageRouteInfo>? children}) : super(AccountRoute.name, initialChildren: children);

  static const String name = 'AccountRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i1.AccountPage();
    },
  );
}

/// generated route for
/// [_i2.LikedMoviesPage]
class LikedMoviesRoute extends _i19.PageRouteInfo<void> {
  const LikedMoviesRoute({List<_i19.PageRouteInfo>? children})
      : super(LikedMoviesRoute.name, initialChildren: children);

  static const String name = 'LikedMoviesRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i2.LikedMoviesPage();
    },
  );
}

/// generated route for
/// [_i3.LikedSeriesPage]
class LikedSeriesRoute extends _i19.PageRouteInfo<void> {
  const LikedSeriesRoute({List<_i19.PageRouteInfo>? children})
      : super(LikedSeriesRoute.name, initialChildren: children);

  static const String name = 'LikedSeriesRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i3.LikedSeriesPage();
    },
  );
}

/// generated route for
/// [_i4.LoginPage]
class LoginRoute extends _i19.PageRouteInfo<void> {
  const LoginRoute({List<_i19.PageRouteInfo>? children}) : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i4.LoginPage();
    },
  );
}

/// generated route for
/// [_i5.MovieDetailsPage]
class MovieDetailsRoute extends _i19.PageRouteInfo<MovieDetailsRouteArgs> {
  MovieDetailsRoute({
    _i20.Key? key,
    required _i21.MovieEntity movie,
    required String heroTag,
    List<_i19.PageRouteInfo>? children,
  }) : super(
          MovieDetailsRoute.name,
          args: MovieDetailsRouteArgs(key: key, movie: movie, heroTag: heroTag),
          initialChildren: children,
        );

  static const String name = 'MovieDetailsRoute';

  static _i19.PageInfo page = _i19.PageInfo(
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

  final _i20.Key? key;

  final _i21.MovieEntity movie;

  final String heroTag;

  @override
  String toString() {
    return 'MovieDetailsRouteArgs{key: $key, movie: $movie, heroTag: $heroTag}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MovieDetailsRouteArgs) return false;
    return key == other.key && movie == other.movie && heroTag == other.heroTag;
  }

  @override
  int get hashCode => key.hashCode ^ movie.hashCode ^ heroTag.hashCode;
}

/// generated route for
/// [_i6.MovieDiscoverPage]
class MovieDiscoverRoute extends _i19.PageRouteInfo<MovieDiscoverRouteArgs> {
  MovieDiscoverRoute({
    _i20.Key? key,
    required String title,
    required _i22.DiscoverSort sort,
    List<_i19.PageRouteInfo>? children,
  }) : super(
          MovieDiscoverRoute.name,
          args: MovieDiscoverRouteArgs(key: key, title: title, sort: sort),
          initialChildren: children,
        );

  static const String name = 'MovieDiscoverRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MovieDiscoverRouteArgs>();
      return _i6.MovieDiscoverPage(
        key: args.key,
        title: args.title,
        sort: args.sort,
      );
    },
  );
}

class MovieDiscoverRouteArgs {
  const MovieDiscoverRouteArgs({
    this.key,
    required this.title,
    required this.sort,
  });

  final _i20.Key? key;

  final String title;

  final _i22.DiscoverSort sort;

  @override
  String toString() {
    return 'MovieDiscoverRouteArgs{key: $key, title: $title, sort: $sort}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MovieDiscoverRouteArgs) return false;
    return key == other.key && title == other.title && sort == other.sort;
  }

  @override
  int get hashCode => key.hashCode ^ title.hashCode ^ sort.hashCode;
}

/// generated route for
/// [_i7.MoviePage]
class MovieRoute extends _i19.PageRouteInfo<void> {
  const MovieRoute({List<_i19.PageRouteInfo>? children}) : super(MovieRoute.name, initialChildren: children);

  static const String name = 'MovieRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i7.MoviePage();
    },
  );
}

/// generated route for
/// [_i8.MovieSearchPage]
class MovieSearchRoute extends _i19.PageRouteInfo<MovieSearchRouteArgs> {
  MovieSearchRoute({
    _i20.Key? key,
    required String heroTag,
    required String hintText,
    List<_i19.PageRouteInfo>? children,
  }) : super(
          MovieSearchRoute.name,
          args: MovieSearchRouteArgs(
            key: key,
            heroTag: heroTag,
            hintText: hintText,
          ),
          initialChildren: children,
        );

  static const String name = 'MovieSearchRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MovieSearchRouteArgs>();
      return _i8.MovieSearchPage(
        key: args.key,
        heroTag: args.heroTag,
        hintText: args.hintText,
      );
    },
  );
}

class MovieSearchRouteArgs {
  const MovieSearchRouteArgs({
    this.key,
    required this.heroTag,
    required this.hintText,
  });

  final _i20.Key? key;

  final String heroTag;

  final String hintText;

  @override
  String toString() {
    return 'MovieSearchRouteArgs{key: $key, heroTag: $heroTag, hintText: $hintText}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MovieSearchRouteArgs) return false;
    return key == other.key && heroTag == other.heroTag && hintText == other.hintText;
  }

  @override
  int get hashCode => key.hashCode ^ heroTag.hashCode ^ hintText.hashCode;
}

/// generated route for
/// [_i9.RegisterPage]
class RegisterRoute extends _i19.PageRouteInfo<void> {
  const RegisterRoute({List<_i19.PageRouteInfo>? children}) : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i9.RegisterPage();
    },
  );
}

/// generated route for
/// [_i10.SeriesDetailsPage]
class SeriesDetailsRoute extends _i19.PageRouteInfo<SeriesDetailsRouteArgs> {
  SeriesDetailsRoute({
    _i20.Key? key,
    required _i23.SeriesEntity series,
    required String heroTag,
    List<_i19.PageRouteInfo>? children,
  }) : super(
          SeriesDetailsRoute.name,
          args: SeriesDetailsRouteArgs(
            key: key,
            series: series,
            heroTag: heroTag,
          ),
          initialChildren: children,
        );

  static const String name = 'SeriesDetailsRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SeriesDetailsRouteArgs>();
      return _i10.SeriesDetailsPage(
        key: args.key,
        series: args.series,
        heroTag: args.heroTag,
      );
    },
  );
}

class SeriesDetailsRouteArgs {
  const SeriesDetailsRouteArgs({
    this.key,
    required this.series,
    required this.heroTag,
  });

  final _i20.Key? key;

  final _i23.SeriesEntity series;

  final String heroTag;

  @override
  String toString() {
    return 'SeriesDetailsRouteArgs{key: $key, series: $series, heroTag: $heroTag}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SeriesDetailsRouteArgs) return false;
    return key == other.key && series == other.series && heroTag == other.heroTag;
  }

  @override
  int get hashCode => key.hashCode ^ series.hashCode ^ heroTag.hashCode;
}

/// generated route for
/// [_i11.SeriesDiscoverPage]
class SeriesDiscoverRoute extends _i19.PageRouteInfo<SeriesDiscoverRouteArgs> {
  SeriesDiscoverRoute({
    _i20.Key? key,
    required String title,
    required _i22.DiscoverSort sort,
    List<_i19.PageRouteInfo>? children,
  }) : super(
          SeriesDiscoverRoute.name,
          args: SeriesDiscoverRouteArgs(key: key, title: title, sort: sort),
          initialChildren: children,
        );

  static const String name = 'SeriesDiscoverRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SeriesDiscoverRouteArgs>();
      return _i11.SeriesDiscoverPage(
        key: args.key,
        title: args.title,
        sort: args.sort,
      );
    },
  );
}

class SeriesDiscoverRouteArgs {
  const SeriesDiscoverRouteArgs({
    this.key,
    required this.title,
    required this.sort,
  });

  final _i20.Key? key;

  final String title;

  final _i22.DiscoverSort sort;

  @override
  String toString() {
    return 'SeriesDiscoverRouteArgs{key: $key, title: $title, sort: $sort}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SeriesDiscoverRouteArgs) return false;
    return key == other.key && title == other.title && sort == other.sort;
  }

  @override
  int get hashCode => key.hashCode ^ title.hashCode ^ sort.hashCode;
}

/// generated route for
/// [_i12.SeriesHomePage]
class SeriesHomeRoute extends _i19.PageRouteInfo<void> {
  const SeriesHomeRoute({List<_i19.PageRouteInfo>? children}) : super(SeriesHomeRoute.name, initialChildren: children);

  static const String name = 'SeriesHomeRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i12.SeriesHomePage();
    },
  );
}

/// generated route for
/// [_i13.SeriesSearchPage]
class SeriesSearchRoute extends _i19.PageRouteInfo<SeriesSearchRouteArgs> {
  SeriesSearchRoute({
    _i20.Key? key,
    required String heroTag,
    required String hintText,
    List<_i19.PageRouteInfo>? children,
  }) : super(
          SeriesSearchRoute.name,
          args: SeriesSearchRouteArgs(
            key: key,
            heroTag: heroTag,
            hintText: hintText,
          ),
          initialChildren: children,
        );

  static const String name = 'SeriesSearchRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SeriesSearchRouteArgs>();
      return _i13.SeriesSearchPage(
        key: args.key,
        heroTag: args.heroTag,
        hintText: args.hintText,
      );
    },
  );
}

class SeriesSearchRouteArgs {
  const SeriesSearchRouteArgs({
    this.key,
    required this.heroTag,
    required this.hintText,
  });

  final _i20.Key? key;

  final String heroTag;

  final String hintText;

  @override
  String toString() {
    return 'SeriesSearchRouteArgs{key: $key, heroTag: $heroTag, hintText: $hintText}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SeriesSearchRouteArgs) return false;
    return key == other.key && heroTag == other.heroTag && hintText == other.hintText;
  }

  @override
  int get hashCode => key.hashCode ^ heroTag.hashCode ^ hintText.hashCode;
}

/// generated route for
/// [_i14.SetProfilePage]
class SetProfileRoute extends _i19.PageRouteInfo<void> {
  const SetProfileRoute({List<_i19.PageRouteInfo>? children}) : super(SetProfileRoute.name, initialChildren: children);

  static const String name = 'SetProfileRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i14.SetProfilePage();
    },
  );
}

/// generated route for
/// [_i15.SettingsPage]
class SettingsRoute extends _i19.PageRouteInfo<void> {
  const SettingsRoute({List<_i19.PageRouteInfo>? children}) : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i15.SettingsPage();
    },
  );
}

/// generated route for
/// [_i16.SplashPage]
class SplashRoute extends _i19.PageRouteInfo<void> {
  const SplashRoute({List<_i19.PageRouteInfo>? children}) : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i16.SplashPage();
    },
  );
}

/// generated route for
/// [_i17.TrailerPage]
class TrailerRoute extends _i19.PageRouteInfo<TrailerRouteArgs> {
  TrailerRoute({
    _i20.Key? key,
    required _i24.VideoEntity trailer,
    List<_i19.PageRouteInfo>? children,
  }) : super(
          TrailerRoute.name,
          args: TrailerRouteArgs(key: key, trailer: trailer),
          initialChildren: children,
        );

  static const String name = 'TrailerRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TrailerRouteArgs>();
      return _i17.TrailerPage(key: args.key, trailer: args.trailer);
    },
  );
}

class TrailerRouteArgs {
  const TrailerRouteArgs({this.key, required this.trailer});

  final _i20.Key? key;

  final _i24.VideoEntity trailer;

  @override
  String toString() {
    return 'TrailerRouteArgs{key: $key, trailer: $trailer}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TrailerRouteArgs) return false;
    return key == other.key && trailer == other.trailer;
  }

  @override
  int get hashCode => key.hashCode ^ trailer.hashCode;
}

/// generated route for
/// [_i18.WrapperPage]
class WrapperRoute extends _i19.PageRouteInfo<void> {
  const WrapperRoute({List<_i19.PageRouteInfo>? children}) : super(WrapperRoute.name, initialChildren: children);

  static const String name = 'WrapperRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i18.WrapperPage();
    },
  );
}

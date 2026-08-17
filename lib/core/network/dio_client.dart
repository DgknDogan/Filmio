import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/env.dart';

/// The single configured [Dio] every TMDB service shares.
///
/// The credentials live here rather than on each Retrofit method, so no call
/// site has to know how the API is authenticated. They go on [BaseOptions]
/// rather than in an interceptor deliberately: the repositories run their
/// requests inside `Isolate.run`, and a plain header map copies across an
/// isolate boundary where a closure-carrying interceptor may not. Move to an
/// interceptor when the token needs refreshing.
Dio buildTmdbDio() {
  if (!hasTmdbToken) {
    debugPrint(
      'TMDB_TOKEN is empty. Run with --dart-define-from-file=env.json '
      '(copy env.example.json and fill in your token).',
    );
  }

  return Dio(
    BaseOptions(
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $tmdbToken',
      },
    ),
  );
}

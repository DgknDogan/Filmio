import 'package:filmio/core/custom/featured_hero.dart';
import 'package:filmio/features/auth/presentation/pages/login_page.dart';
import 'package:filmio/features/movie/presentation/bloc/movie_bloc.dart';
import 'package:filmio/features/movie/presentation/pages/movie_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'helpers/app_launcher.dart';

void main() {
  patrolTest('an unauthenticated launch lands on the login screen', ($) async {
    await createApp($);
    await waitPastSplash($);

    // The one thing unit tests cannot check: that DI, the router, the splash
    // cubit and the real Firebase session agree on where a cold start goes.
    expect($(LoginPage).exists, true);
  });

  patrolTest('the films tab opens on a title the recommendation service picked', ($) async {
    await createApp($);
    await waitPastSplash($);
    await signIn($);

    await $(MoviePage).waitUntilVisible();

    final bloc = BlocProvider.of<MovieBloc>($.tester.element($(MoviePage).finder.first));
    final recommended = await _settledRecommendation($, bloc);

    // What no unit test can reach: a real Firebase ID token, minted for this
    // account, accepted by Filmio's own service on Cloud Run — and the id it
    // answers with resolving to a title at TMDB, whose credentials are a
    // different header on the same Dio.
    expect(
      recommended,
      isA<RecommendedMovieLoaded>(),
      reason: recommended is RecommendedMovieFailure ? 'the recommendation failed: ${recommended.message}' : 'no recommendation resolved',
    );

    // And that the title it resolved to is the one drawn at the head of the tab.
    await $(FeaturedHero).waitUntilVisible();
    expect($((recommended as RecommendedMovieLoaded).movie.title!).exists, true);
  });
}

/// The recommendation once it has stopped loading.
///
/// Two live services answer behind it, so it is waited for rather than read —
/// and waited for by polling the bloc instead of by settling, because the tab
/// shimmers while it waits and a shimmer never settles.
Future<RecommendedMovieState> _settledRecommendation(PatrolIntegrationTester $, MovieBloc bloc) async {
  for (var attempt = 0; attempt < 40; attempt++) {
    final state = bloc.state;
    if (state is MovieSuccess && state.recommended is! RecommendedMovieLoading) {
      return state.recommended;
    }
    await $.pump(const Duration(milliseconds: 500));
  }

  return const RecommendedMovieLoading();
}

import 'package:filmio/core/custom/featured_hero.dart';
import 'package:filmio/features/movie/presentation/pages/movie_page.dart';
import 'package:filmio/features/series/presentation/bloc/series_bloc.dart';
import 'package:filmio/features/series/presentation/pages/series_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'helpers/app_launcher.dart';

void main() {
  patrolTest('the series tab opens on a series the recommendation service picked', ($) async {
    await createApp($);
    await waitPastSplash($);
    await signIn($);

    // The app opens on films; the series tab is the second stop on the bar.
    await $(MoviePage).waitUntilVisible();
    await $(#seriesTab).tap(settlePolicy: SettlePolicy.trySettle);

    await $(SeriesHomePage).waitUntilVisible();

    final bloc = BlocProvider.of<SeriesBloc>($.tester.element($(SeriesHomePage).finder.first));
    final recommended = await waitFor($, () {
      final state = bloc.state;
      return state is SeriesSuccess && state.recommended is! RecommendedSeriesLoading ? state.recommended : null;
    });

    // The television half of the same wiring: `/recommendations/series` on
    // Cloud Run with the user's own token, then `/tv/{id}` at TMDB.
    expect(
      recommended,
      isA<RecommendedSeriesLoaded>(),
      reason: recommended is RecommendedSeriesFailure ? 'the recommendation failed: ${recommended.message}' : 'no recommendation resolved',
    );

    await $(FeaturedHero).waitUntilVisible();
    expect($((recommended as RecommendedSeriesLoaded).series.name!).exists, true);
  });
}

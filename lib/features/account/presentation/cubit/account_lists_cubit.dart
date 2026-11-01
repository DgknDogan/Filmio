import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../movie/domain/entities/movie.dart';
import '../../../movie/domain/usecases/get_liked_movies.dart';
import '../../../movie/domain/usecases/get_watchlist_movies.dart';
import '../../../series/domain/entities/series_entity.dart';
import '../../../series/domain/usecases/get_liked_series.dart';
import '../../../series/domain/usecases/get_watchlist_series.dart';
import '../../domain/entities/taste_profile.dart';

part 'account_lists_state.dart';

/// What the account tab knows about its own four lists: enough of each to show
/// a few covers against the row that opens it, and the profile they add up to.
///
/// All four live on the same user document, so this is four reads of one
/// record — asked for together rather than one after another, because the tab
/// shows them in one block.
class AccountListsCubit extends Cubit<AccountListsState> {
  final GetLikedMoviesUseCase _getLikedMovies;
  final GetLikedSeriesUseCase _getLikedSeries;
  final GetWatchlistMoviesUseCase _getWatchlistMovies;
  final GetWatchlistSeriesUseCase _getWatchlistSeries;

  AccountListsCubit(
    this._getLikedMovies,
    this._getLikedSeries,
    this._getWatchlistMovies,
    this._getWatchlistSeries,
  ) : super(const AccountListsLoading()) {
    load();
  }

  /// Reads all four lists.
  ///
  /// Called again when the reader comes back from one of the list screens or
  /// a title's own page, either of which can have changed what is in them.
  Future<void> load() async {
    // All four started before any is awaited, so they go out together — but
    // awaited one at a time rather than through `Future.wait`, which would
    // collapse them to a common type and need casting back.
    final likedMoviesRead = _getLikedMovies.call();
    final likedSeriesRead = _getLikedSeries.call();
    final watchlistMoviesRead = _getWatchlistMovies.call();
    final watchlistSeriesRead = _getWatchlistSeries.call();

    final likedMovies = _titles(await likedMoviesRead);
    final likedSeries = _titles(await likedSeriesRead);
    final watchlistMovies = _titles(await watchlistMoviesRead);
    final watchlistSeries = _titles(await watchlistSeriesRead);

    if (isClosed) return;

    // Any one of them failing means the figures would be wrong rather than
    // missing — a profile reading "no series liked" because one read did not
    // come back describes somebody else. The tab shows the rows without their
    // detail instead, and the list screens report the failure properly when
    // one is opened.
    if ([likedMovies, likedSeries, watchlistMovies, watchlistSeries].any((titles) => titles == null)) {
      emit(const AccountListsUnavailable());
      return;
    }

    emit(
      AccountListsLoaded(
        likedMovies: likedMovies!,
        likedSeries: likedSeries!,
        watchlistMovies: watchlistMovies!,
        watchlistSeries: watchlistSeries!,
        profile: TasteProfile.from(
          likedMovies: likedMovies,
          likedSeries: likedSeries,
          watchlistMovies: watchlistMovies,
          watchlistSeries: watchlistSeries,
        ),
      ),
    );
  }

  /// The titles a read came back with, or null when it failed.
  static List<T>? _titles<T>(Either<Failure, List<T>> result) {
    return result.fold((failure) => null, (titles) => titles);
  }
}

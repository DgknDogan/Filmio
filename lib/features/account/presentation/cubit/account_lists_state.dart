part of 'account_lists_cubit.dart';

sealed class AccountListsState extends Equatable {
  const AccountListsState();

  @override
  List<Object?> get props => [];
}

final class AccountListsLoading extends AccountListsState {
  const AccountListsLoading();
}

/// One of the reads did not come back.
///
/// Not a failure state with a message: nothing on this tab depends on these
/// lists to work. The rows still open, and the screen behind each one is where
/// a reader who cares is told what went wrong.
final class AccountListsUnavailable extends AccountListsState {
  const AccountListsUnavailable();
}

final class AccountListsLoaded extends AccountListsState {
  final List<MovieEntity> likedMovies;
  final List<SeriesEntity> likedSeries;
  final List<MovieEntity> watchlistMovies;
  final List<SeriesEntity> watchlistSeries;
  final TasteProfile profile;

  const AccountListsLoaded({
    required this.likedMovies,
    required this.likedSeries,
    required this.watchlistMovies,
    required this.watchlistSeries,
    required this.profile,
  });

  @override
  List<Object?> get props => [likedMovies, likedSeries, watchlistMovies, watchlistSeries, profile];
}

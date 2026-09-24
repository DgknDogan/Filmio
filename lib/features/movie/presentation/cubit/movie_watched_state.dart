part of 'movie_watched_cubit.dart';

class MovieWatchedState extends Equatable {
  final bool isWatched;

  /// True while the stored flag is being read or written, so the button waits
  /// instead of firing the same change twice.
  final bool isBusy;

  const MovieWatchedState({required this.isWatched, required this.isBusy});

  MovieWatchedState copyWith({bool? isWatched, bool? isBusy}) {
    return MovieWatchedState(
      isWatched: isWatched ?? this.isWatched,
      isBusy: isBusy ?? this.isBusy,
    );
  }

  @override
  List<Object?> get props => [isWatched, isBusy];
}

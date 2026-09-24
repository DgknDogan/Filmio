part of 'series_watched_cubit.dart';

class SeriesWatchedState extends Equatable {
  final bool isWatched;

  /// True while the stored flag is being read or written, so the button waits
  /// instead of firing the same change twice.
  final bool isBusy;

  const SeriesWatchedState({required this.isWatched, required this.isBusy});

  SeriesWatchedState copyWith({bool? isWatched, bool? isBusy}) {
    return SeriesWatchedState(
      isWatched: isWatched ?? this.isWatched,
      isBusy: isBusy ?? this.isBusy,
    );
  }

  @override
  List<Object?> get props => [isWatched, isBusy];
}

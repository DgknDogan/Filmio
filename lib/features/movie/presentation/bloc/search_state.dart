part of 'search_bloc.dart';

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// Nothing typed yet.
final class SearchInitial extends SearchState {
  const SearchInitial();
}

final class SearchLoading extends SearchState {
  const SearchLoading();
}

final class SearchLoaded extends SearchState {
  final List<MovieEntity> movies;

  const SearchLoaded(this.movies);

  @override
  List<Object?> get props => [movies];
}

final class SearchFailure extends SearchState {
  final String message;

  const SearchFailure(this.message);

  @override
  List<Object?> get props => [message];
}

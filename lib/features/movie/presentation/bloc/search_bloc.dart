import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/utils/event_transformers.dart';
import '../../domain/entities/movie.dart';
import '../../domain/usecases/search_movies.dart';

part 'search_event.dart';
part 'search_state.dart';

/// A Bloc rather than a Cubit because the timing of the events is the whole
/// point: a keystroke is not a search, and the transformer is what decides
/// which of them becomes one.
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchMoviesUseCase _searchMoviesUseCase;

  SearchBloc(this._searchMoviesUseCase) : super(const SearchInitial()) {
    on<SearchQueryChanged>(_onQueryChanged, transformer: debounceRestartable());
    on<SearchRetried>(_onRetried);
  }

  Future<void> _onQueryChanged(SearchQueryChanged event, Emitter<SearchState> emit) => _search(event.query, emit);

  /// Deliberately outside the transformer: the reader has already waited for
  /// one failed request and asked for it again on purpose, so making them wait
  /// out the debounce would read as the button not working.
  Future<void> _onRetried(SearchRetried event, Emitter<SearchState> emit) => _search(event.query, emit);

  Future<void> _search(String query, Emitter<SearchState> emit) async {
    if (query.isEmpty) {
      emit(const SearchInitial());
      return;
    }

    emit(const SearchLoading());

    final result = await _searchMoviesUseCase.call(params: query);

    // The screen can be popped, or a newer query can have replaced this one,
    // while the request was in the air.
    if (emit.isDone) return;

    result.fold(
      (failure) => emit(SearchFailure(failure.message)),
      (movies) => emit(SearchLoaded(movies.where((movie) => movie.posterPath != null).toList())),
    );
  }
}

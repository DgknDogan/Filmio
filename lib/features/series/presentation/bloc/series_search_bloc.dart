import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/utils/event_transformers.dart';
import '../../domain/entities/series_entity.dart';
import '../../domain/usecases/search_series.dart';

part 'series_search_event.dart';
part 'series_search_state.dart';

/// A Bloc rather than a Cubit because the timing of the events is the whole
/// point: a keystroke is not a search, and the transformer is what decides
/// which of them becomes one.
class SeriesSearchBloc extends Bloc<SeriesSearchEvent, SeriesSearchState> {
  final SearchSeriesUseCase _searchSeriesUseCase;

  SeriesSearchBloc(this._searchSeriesUseCase) : super(const SeriesSearchInitial()) {
    on<SeriesSearchQueryChanged>(_onQueryChanged, transformer: debounceRestartable());
    on<SeriesSearchRetried>(_onRetried);
  }

  Future<void> _onQueryChanged(SeriesSearchQueryChanged event, Emitter<SeriesSearchState> emit) => _search(event.query, emit);

  /// Deliberately outside the transformer: the reader has already waited for
  /// one failed request and asked for it again on purpose, so making them wait
  /// out the debounce would read as the button not working.
  Future<void> _onRetried(SeriesSearchRetried event, Emitter<SeriesSearchState> emit) => _search(event.query, emit);

  Future<void> _search(String query, Emitter<SeriesSearchState> emit) async {
    if (query.isEmpty) {
      emit(const SeriesSearchInitial());
      return;
    }

    emit(const SeriesSearchLoading());

    final result = await _searchSeriesUseCase.call(params: query);

    // The screen can be popped, or a newer query can have replaced this one,
    // while the request was in the air.
    if (emit.isDone) return;

    result.fold(
      (failure) => emit(SeriesSearchFailure(failure.message)),
      (series) => emit(SeriesSearchLoaded(series.where((item) => item.posterPath != null).toList())),
    );
  }
}

import 'package:bloc/bloc.dart';

import '../../domain/entities/movie.dart';
import '../../domain/usecases/search_movies.dart';

part '../states/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchMoviesUseCase _searchMoviesUseCase;
  SearchCubit(this._searchMoviesUseCase) : super(SearchState(searchedMovies: []));

  void searchMovies({required String query}) async {
    final dataState = await _searchMoviesUseCase.call(params: query);

    if (dataState.data != null && !isClosed) {
      emit(
        SearchState(
          searchedMovies: dataState.data!
              .where(
                (element) => element.posterPath != null,
              )
              .toList(),
        ),
      );
    }
  }
}

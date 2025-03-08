import '../../../../core/resources/data_state.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/movie.dart';
import '../repository/movie_repository.dart';

class SearchMoviesUseCase extends UseCase<DataState<List<MovieEntity>>, String> {
  final MovieRepository _movieRepository;

  SearchMoviesUseCase(this._movieRepository);
  @override
  Future<DataState<List<MovieEntity>>> call({String? params}) {
    return _movieRepository.searchMoviesByTitle(query: params!);
  }
}

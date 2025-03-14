import '../../../../core/resources/data_state.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/movie.dart';
import '../repository/movie_repository.dart';

class GetSimilarMoviesUseCase extends UseCase<DataState<List<MovieEntity>>, int> {
  final MovieRepository _movieRepository;

  GetSimilarMoviesUseCase(this._movieRepository);

  @override
  Future<DataState<List<MovieEntity>>> call({int? params}) async {
    return await _movieRepository.getSimilarMovies(movieId: params!);
  }
}

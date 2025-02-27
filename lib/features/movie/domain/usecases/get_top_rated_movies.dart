import '../../../../core/resources/data_state.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/movie.dart';
import '../repository/movie_repository.dart';

class GetTopRatedMoviesUseCase implements UseCase<DataState<List<MovieEntity>>, void> {
  final MovieRepository _movieRepository;

  GetTopRatedMoviesUseCase(this._movieRepository);

  @override
  Future<DataState<List<MovieEntity>>> call({void params}) {
    return _movieRepository.getTopRatedMovies();
  }
}

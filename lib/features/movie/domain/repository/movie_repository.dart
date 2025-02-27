import '../../../../core/resources/data_state.dart';
import '../entities/movie.dart';

abstract class MovieRepository {
  Future<DataState<List<MovieEntity>>> getPopularMovies();
  Future<DataState<List<MovieEntity>>> getTopRatedMovies();
}

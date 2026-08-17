import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../entities/movie.dart';

abstract class MovieRepository {
  Future<Either<Failure, List<MovieEntity>>> getPopularMovies();
  Future<Either<Failure, List<MovieEntity>>> getTopRatedMovies();
  Future<Either<Failure, List<MovieEntity>>> searchMoviesByTitle({required String query});
  Future<Either<Failure, List<MovieEntity>>> getSimilarMovies({required int movieId});
}

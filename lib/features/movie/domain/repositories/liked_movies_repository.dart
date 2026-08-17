import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../entities/movie.dart';

abstract class LikedMoviesRepository {
  Future<Either<Failure, List<MovieEntity>>> getLikedMovies();

  /// Right carries [unit]: succeeding is the whole result, there is nothing to
  /// hand back.
  Future<Either<Failure, Unit>> likeMovie({required MovieEntity movie});
  Future<Either<Failure, Unit>> dislikeMovie({required MovieEntity movie});
}

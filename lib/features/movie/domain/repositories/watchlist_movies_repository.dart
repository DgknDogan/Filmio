import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../entities/movie.dart';

/// The films an account means to watch, which is a different question from
/// the ones it liked: a like says something about a film already seen, and
/// this says only that it caught the reader's eye.
abstract class WatchlistMoviesRepository {
  Future<Either<Failure, List<MovieEntity>>> getWatchlistMovies();

  /// Right carries [unit]: succeeding is the whole result, there is nothing to
  /// hand back.
  Future<Either<Failure, Unit>> addToWatchlist({required MovieEntity movie});
  Future<Either<Failure, Unit>> removeFromWatchlist({required MovieEntity movie});
}

import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';

/// The films the signed-in user has marked watched. Only ids are kept:
/// the titles themselves are always read fresh from the catalogue.
abstract class WatchedMoviesRepository {
  /// Most recently marked first.
  Future<Either<Failure, List<int>>> getWatchedMovieIds();

  Future<Either<Failure, bool>> isMovieWatched({required int movieId});

  /// Right carries [unit]: succeeding is the whole result, there is nothing to
  /// hand back.
  Future<Either<Failure, Unit>> addWatchedMovie({required int movieId});
  Future<Either<Failure, Unit>> removeWatchedMovie({required int movieId});
}

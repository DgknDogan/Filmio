import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';

/// The series the signed-in user has marked watched. Only ids are kept:
/// the titles themselves are always read fresh from the catalogue.
abstract class WatchedSeriesRepository {
  /// Most recently marked first.
  Future<Either<Failure, List<int>>> getWatchedSeriesIds();

  Future<Either<Failure, bool>> isSeriesWatched({required int seriesId});

  /// Right carries [unit]: succeeding is the whole result, there is nothing to
  /// hand back.
  Future<Either<Failure, Unit>> addWatchedSeries({required int seriesId});
  Future<Either<Failure, Unit>> removeWatchedSeries({required int seriesId});
}

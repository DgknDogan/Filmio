import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../entities/series_entity.dart';

/// The series an account means to watch. Same distinction from the liked list
/// as the films — see [WatchlistMoviesRepository].
abstract class WatchlistSeriesRepository {
  Future<Either<Failure, List<SeriesEntity>>> getWatchlistSeries();

  /// Right carries [unit]: succeeding is the whole result, there is nothing to
  /// hand back.
  Future<Either<Failure, Unit>> addToWatchlist({required SeriesEntity series});
  Future<Either<Failure, Unit>> removeFromWatchlist({required SeriesEntity series});
}

import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../entities/series_entity.dart';

abstract class LikedSeriesRepository {
  Future<Either<Failure, List<SeriesEntity>>> getLikedSeries();

  /// Right carries [unit]: succeeding is the whole result, there is nothing to
  /// hand back.
  Future<Either<Failure, Unit>> likeSeries({required SeriesEntity series});
  Future<Either<Failure, Unit>> dislikeSeries({required SeriesEntity series});
}

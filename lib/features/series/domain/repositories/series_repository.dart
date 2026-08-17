import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../entities/series_entity.dart';

abstract class SeriesRepository {
  Future<Either<Failure, List<SeriesEntity>>> getPopularSeries();
  Future<Either<Failure, List<SeriesEntity>>> getTopRatedSeries();
  Future<Either<Failure, List<SeriesEntity>>> searchSeries({required String query});
  Future<Either<Failure, List<SeriesEntity>>> getSimilarSeries({required int seriesId});
}

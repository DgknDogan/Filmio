import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/series_entity.dart';
import '../repositories/series_repository.dart';

/// The titles at the head of the series tab, best first.
class GetRecommendedSeriesUseCase implements UseCase<Either<Failure, List<SeriesEntity>>, int> {
  final SeriesRepository _seriesRepository;

  GetRecommendedSeriesUseCase(this._seriesRepository);

  /// [params] is the count to ask for; omitted, the service decides.
  @override
  Future<Either<Failure, List<SeriesEntity>>> call({int? params}) {
    return _seriesRepository.getRecommendedSeries(limit: params);
  }
}

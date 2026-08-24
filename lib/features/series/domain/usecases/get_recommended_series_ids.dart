import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/series_repository.dart';

/// The ids only — turning one into a series is a second call, and the caller
/// decides how many of them it wants to make.
class GetRecommendedSeriesIdsUseCase implements UseCase<Either<Failure, List<int>>, int> {
  final SeriesRepository _seriesRepository;

  GetRecommendedSeriesIdsUseCase(this._seriesRepository);

  /// [params] is the count to ask for; omitted, the service decides.
  @override
  Future<Either<Failure, List<int>>> call({int? params}) {
    return _seriesRepository.getRecommendedSeriesIds(limit: params);
  }
}

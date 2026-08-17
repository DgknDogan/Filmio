import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/series_entity.dart';
import '../repositories/series_repository.dart';

class GetPopularSeriesUseCase extends UseCase<Either<Failure, List<SeriesEntity>>, void> {
  final SeriesRepository _seriesRepository;

  GetPopularSeriesUseCase(this._seriesRepository);

  @override
  Future<Either<Failure, List<SeriesEntity>>> call({void params}) {
    return _seriesRepository.getPopularSeries();
  }
}

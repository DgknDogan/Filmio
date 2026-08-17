import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/series_entity.dart';
import '../repositories/series_repository.dart';

class GetSimilarSeriesUseCase extends UseCase<Either<Failure, List<SeriesEntity>>, int> {
  final SeriesRepository _seriesRepository;

  GetSimilarSeriesUseCase(this._seriesRepository);

  @override
  Future<Either<Failure, List<SeriesEntity>>> call({int? params}) async {
    return await _seriesRepository.getSimilarSeries(seriesId: params!);
  }
}

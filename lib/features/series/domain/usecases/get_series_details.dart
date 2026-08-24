import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/series_entity.dart';
import '../repositories/series_repository.dart';

class GetSeriesDetailsUseCase implements UseCase<Either<Failure, SeriesEntity>, int> {
  final SeriesRepository _seriesRepository;

  GetSeriesDetailsUseCase(this._seriesRepository);

  @override
  Future<Either<Failure, SeriesEntity>> call({int? params}) {
    return _seriesRepository.getSeriesDetails(seriesId: params!);
  }
}

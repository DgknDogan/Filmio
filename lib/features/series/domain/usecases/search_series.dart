import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/series_entity.dart';
import '../repositories/series_repository.dart';

class SearchSeriesUseCase extends UseCase<Either<Failure, List<SeriesEntity>>, String> {
  final SeriesRepository _movieRepository;

  SearchSeriesUseCase(this._movieRepository);
  @override
  Future<Either<Failure, List<SeriesEntity>>> call({String? params}) {
    return _movieRepository.searchSeries(query: params!);
  }
}

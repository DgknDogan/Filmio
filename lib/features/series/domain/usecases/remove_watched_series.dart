import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/watched_series_repository.dart';

class RemoveWatchedSeriesUseCase extends UseCase<Either<Failure, Unit>, int> {
  final WatchedSeriesRepository _watchedSeriesRepository;

  RemoveWatchedSeriesUseCase(this._watchedSeriesRepository);

  @override
  Future<Either<Failure, Unit>> call({int? params}) {
    return _watchedSeriesRepository.removeWatchedSeries(seriesId: params!);
  }
}

import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/watched_series_repository.dart';

class AddWatchedSeriesUseCase extends UseCase<Either<Failure, Unit>, int> {
  final WatchedSeriesRepository _watchedSeriesRepository;

  AddWatchedSeriesUseCase(this._watchedSeriesRepository);

  @override
  Future<Either<Failure, Unit>> call({int? params}) {
    return _watchedSeriesRepository.addWatchedSeries(seriesId: params!);
  }
}

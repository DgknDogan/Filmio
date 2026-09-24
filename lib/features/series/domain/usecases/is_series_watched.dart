import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/watched_series_repository.dart';

class IsSeriesWatchedUseCase extends UseCase<Either<Failure, bool>, int> {
  final WatchedSeriesRepository _watchedSeriesRepository;

  IsSeriesWatchedUseCase(this._watchedSeriesRepository);

  @override
  Future<Either<Failure, bool>> call({int? params}) {
    return _watchedSeriesRepository.isSeriesWatched(seriesId: params!);
  }
}

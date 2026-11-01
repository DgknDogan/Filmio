import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/series_entity.dart';
import '../repositories/watchlist_series_repository.dart';

class GetWatchlistSeriesUseCase extends UseCase<Either<Failure, List<SeriesEntity>>, void> {
  final WatchlistSeriesRepository _watchlistSeriesRepository;

  GetWatchlistSeriesUseCase(this._watchlistSeriesRepository);

  @override
  Future<Either<Failure, List<SeriesEntity>>> call({void params}) {
    return _watchlistSeriesRepository.getWatchlistSeries();
  }
}

import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/series_entity.dart';
import '../repositories/watchlist_series_repository.dart';

class AddSeriesToWatchlistUseCase extends UseCase<Either<Failure, Unit>, SeriesEntity> {
  final WatchlistSeriesRepository _watchlistSeriesRepository;

  AddSeriesToWatchlistUseCase(this._watchlistSeriesRepository);

  @override
  Future<Either<Failure, Unit>> call({SeriesEntity? params}) {
    return _watchlistSeriesRepository.addToWatchlist(series: params!);
  }
}

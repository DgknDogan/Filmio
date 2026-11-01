import '../../../../core/cubit/title_list_cubit.dart';
import '../../../series/domain/entities/series_entity.dart';
import '../../../series/domain/usecases/get_watchlist_series.dart';

/// The series-to-watch screen — see [LikedMoviesCubit].
class WatchlistSeriesCubit extends TitleListCubit<SeriesEntity> {
  WatchlistSeriesCubit(GetWatchlistSeriesUseCase getWatchlistSeries) : super(getWatchlistSeries.call);
}

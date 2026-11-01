import '../../../../core/cubit/title_flag_cubit.dart';
import '../../domain/entities/series_entity.dart';
import '../../domain/usecases/add_series_to_watchlist.dart';
import '../../domain/usecases/get_watchlist_series.dart';
import '../../domain/usecases/remove_series_from_watchlist.dart';

/// The bookmark on a series' details screen — see [MovieWatchlistCubit].
class SeriesWatchlistCubit extends TitleFlagCubit<SeriesEntity> {
  SeriesWatchlistCubit(
    GetWatchlistSeriesUseCase getWatchlist,
    AddSeriesToWatchlistUseCase addToWatchlist,
    RemoveSeriesFromWatchlistUseCase removeFromWatchlist,
    SeriesEntity series,
  ) : super(
          readList: getWatchlist.call,
          add: (series) => addToWatchlist.call(params: series),
          remove: (series) => removeFromWatchlist.call(params: series),
          title: series,
          idOf: (series) => series.id,
        );
}

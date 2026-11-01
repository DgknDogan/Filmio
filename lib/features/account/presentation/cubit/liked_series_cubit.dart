import '../../../../core/cubit/title_list_cubit.dart';
import '../../../series/domain/entities/series_entity.dart';
import '../../../series/domain/usecases/get_liked_series.dart';

/// The liked series screen — see [LikedMoviesCubit].
class LikedSeriesCubit extends TitleListCubit<SeriesEntity> {
  LikedSeriesCubit(GetLikedSeriesUseCase getLikedSeries) : super(getLikedSeries.call);
}

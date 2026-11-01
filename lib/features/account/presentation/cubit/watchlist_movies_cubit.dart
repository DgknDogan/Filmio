import '../../../../core/cubit/title_list_cubit.dart';
import '../../../movie/domain/entities/movie.dart';
import '../../../movie/domain/usecases/get_watchlist_movies.dart';

/// The films-to-watch screen — see [LikedMoviesCubit].
class WatchlistMoviesCubit extends TitleListCubit<MovieEntity> {
  WatchlistMoviesCubit(GetWatchlistMoviesUseCase getWatchlistMovies) : super(getWatchlistMovies.call);
}

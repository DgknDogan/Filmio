import '../../../../core/cubit/title_flag_cubit.dart';
import '../../domain/entities/movie.dart';
import '../../domain/usecases/add_movie_to_watchlist.dart';
import '../../domain/usecases/get_watchlist_movies.dart';
import '../../domain/usecases/remove_movie_from_watchlist.dart';

/// The bookmark on a film's details screen. All of the behaviour is
/// [TitleFlagCubit]'s; this says which list it is about.
class MovieWatchlistCubit extends TitleFlagCubit<MovieEntity> {
  MovieWatchlistCubit(
    GetWatchlistMoviesUseCase getWatchlist,
    AddMovieToWatchlistUseCase addToWatchlist,
    RemoveMovieFromWatchlistUseCase removeFromWatchlist,
    MovieEntity movie,
  ) : super(
          readList: getWatchlist.call,
          add: (movie) => addToWatchlist.call(params: movie),
          remove: (movie) => removeFromWatchlist.call(params: movie),
          title: movie,
          idOf: (movie) => movie.id,
        );
}

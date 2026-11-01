import '../../../../core/cubit/title_list_cubit.dart';
import '../../../movie/domain/entities/movie.dart';
import '../../../movie/domain/usecases/get_liked_movies.dart';

/// The liked films screen. All of the behaviour is [TitleListCubit]'s; this
/// says which list it is reading and gives the screen a type to provide.
class LikedMoviesCubit extends TitleListCubit<MovieEntity> {
  LikedMoviesCubit(GetLikedMoviesUseCase getLikedMovies) : super(getLikedMovies.call);
}

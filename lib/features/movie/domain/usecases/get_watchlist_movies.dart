import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/movie.dart';
import '../repositories/watchlist_movies_repository.dart';

class GetWatchlistMoviesUseCase extends UseCase<Either<Failure, List<MovieEntity>>, void> {
  final WatchlistMoviesRepository _watchlistMoviesRepository;

  GetWatchlistMoviesUseCase(this._watchlistMoviesRepository);

  @override
  Future<Either<Failure, List<MovieEntity>>> call({void params}) {
    return _watchlistMoviesRepository.getWatchlistMovies();
  }
}

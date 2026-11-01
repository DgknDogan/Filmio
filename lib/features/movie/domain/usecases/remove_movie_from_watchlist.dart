import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/movie.dart';
import '../repositories/watchlist_movies_repository.dart';

class RemoveMovieFromWatchlistUseCase extends UseCase<Either<Failure, Unit>, MovieEntity> {
  final WatchlistMoviesRepository _watchlistMoviesRepository;

  RemoveMovieFromWatchlistUseCase(this._watchlistMoviesRepository);

  @override
  Future<Either<Failure, Unit>> call({MovieEntity? params}) {
    return _watchlistMoviesRepository.removeFromWatchlist(movie: params!);
  }
}

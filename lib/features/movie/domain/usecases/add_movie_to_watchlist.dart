import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/movie.dart';
import '../repositories/watchlist_movies_repository.dart';

class AddMovieToWatchlistUseCase extends UseCase<Either<Failure, Unit>, MovieEntity> {
  final WatchlistMoviesRepository _watchlistMoviesRepository;

  AddMovieToWatchlistUseCase(this._watchlistMoviesRepository);

  @override
  Future<Either<Failure, Unit>> call({MovieEntity? params}) {
    return _watchlistMoviesRepository.addToWatchlist(movie: params!);
  }
}

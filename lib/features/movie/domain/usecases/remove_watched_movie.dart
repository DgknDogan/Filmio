import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/watched_movies_repository.dart';

class RemoveWatchedMovieUseCase extends UseCase<Either<Failure, Unit>, int> {
  final WatchedMoviesRepository _watchedMoviesRepository;

  RemoveWatchedMovieUseCase(this._watchedMoviesRepository);

  @override
  Future<Either<Failure, Unit>> call({int? params}) {
    return _watchedMoviesRepository.removeWatchedMovie(movieId: params!);
  }
}

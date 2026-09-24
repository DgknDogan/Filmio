import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/watched_movies_repository.dart';

class IsMovieWatchedUseCase extends UseCase<Either<Failure, bool>, int> {
  final WatchedMoviesRepository _watchedMoviesRepository;

  IsMovieWatchedUseCase(this._watchedMoviesRepository);

  @override
  Future<Either<Failure, bool>> call({int? params}) {
    return _watchedMoviesRepository.isMovieWatched(movieId: params!);
  }
}

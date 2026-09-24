import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/watched_movies_repository.dart';

class AddWatchedMovieUseCase extends UseCase<Either<Failure, Unit>, int> {
  final WatchedMoviesRepository _watchedMoviesRepository;

  AddWatchedMovieUseCase(this._watchedMoviesRepository);

  @override
  Future<Either<Failure, Unit>> call({int? params}) {
    return _watchedMoviesRepository.addWatchedMovie(movieId: params!);
  }
}

import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/movie.dart';
import '../repositories/movie_repository.dart';
import '../repositories/watched_movies_repository.dart';

/// The watched list as titles: the stored ids, each looked up in the
/// catalogue — together, since none waits on another — and kept in the order
/// they were marked.
///
/// A title the catalogue cannot answer for is left out rather than sinking the
/// rest. Only when none comes back does the list fail, and then with the most
/// recent title's reason.
class GetWatchedMoviesUseCase extends UseCase<Either<Failure, List<MovieEntity>>, void> {
  final WatchedMoviesRepository _watchedMoviesRepository;
  final MovieRepository _movieRepository;

  GetWatchedMoviesUseCase(this._watchedMoviesRepository, this._movieRepository);

  @override
  Future<Either<Failure, List<MovieEntity>>> call({void params}) async {
    final idsResult = await _watchedMoviesRepository.getWatchedMovieIds();

    return idsResult.fold(
      (failure) async => Left(failure),
      (ids) async {
        if (ids.isEmpty) return const Right([]);

        final results = await Future.wait(ids.map((id) => _movieRepository.getMovieDetails(movieId: id)));

        final titles = <MovieEntity>[];
        final failures = <Failure>[];
        for (final result in results) {
          result.fold(failures.add, titles.add);
        }

        return titles.isEmpty ? Left(failures.first) : Right(titles);
      },
    );
  }
}

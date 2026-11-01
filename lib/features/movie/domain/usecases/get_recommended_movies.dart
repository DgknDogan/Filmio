import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

/// The titles at the head of the films tab, best first.
class GetRecommendedMoviesUseCase implements UseCase<Either<Failure, List<MovieEntity>>, int> {
  final MovieRepository _movieRepository;

  GetRecommendedMoviesUseCase(this._movieRepository);

  /// [params] is the count to ask for; omitted, the service decides.
  @override
  Future<Either<Failure, List<MovieEntity>>> call({int? params}) {
    return _movieRepository.getRecommendedMovies(limit: params);
  }
}

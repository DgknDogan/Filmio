import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/movie_repository.dart';

/// The ids only — turning one into a title is a second call, and the caller
/// decides how many of them it wants to make.
class GetRecommendedMovieIdsUseCase implements UseCase<Either<Failure, List<int>>, int> {
  final MovieRepository _movieRepository;

  GetRecommendedMovieIdsUseCase(this._movieRepository);

  /// [params] is the count to ask for; omitted, the service decides.
  @override
  Future<Either<Failure, List<int>>> call({int? params}) {
    return _movieRepository.getRecommendedMovieIds(limit: params);
  }
}

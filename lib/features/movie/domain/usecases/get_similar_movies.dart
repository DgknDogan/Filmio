import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class GetSimilarMoviesUseCase extends UseCase<Either<Failure, List<MovieEntity>>, int> {
  final MovieRepository _movieRepository;

  GetSimilarMoviesUseCase(this._movieRepository);

  @override
  Future<Either<Failure, List<MovieEntity>>> call({int? params}) async {
    return await _movieRepository.getSimilarMovies(movieId: params!);
  }
}

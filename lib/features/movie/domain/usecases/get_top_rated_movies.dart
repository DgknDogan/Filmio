import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class GetTopRatedMoviesUseCase implements UseCase<Either<Failure, List<MovieEntity>>, void> {
  final MovieRepository _movieRepository;

  GetTopRatedMoviesUseCase(this._movieRepository);

  @override
  Future<Either<Failure, List<MovieEntity>>> call({void params}) {
    return _movieRepository.getTopRatedMovies();
  }
}

import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class GetMovieDetailsUseCase implements UseCase<Either<Failure, MovieEntity>, int> {
  final MovieRepository _movieRepository;

  GetMovieDetailsUseCase(this._movieRepository);

  @override
  Future<Either<Failure, MovieEntity>> call({int? params}) {
    return _movieRepository.getMovieDetails(movieId: params!);
  }
}

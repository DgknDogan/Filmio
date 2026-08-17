import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/movie.dart';
import '../repositories/liked_movies_repository.dart';

class GetLikedMoviesUseCase extends UseCase<Either<Failure, List<MovieEntity>>, void> {
  final LikedMoviesRepository _likedMoviesRepository;

  GetLikedMoviesUseCase(this._likedMoviesRepository);

  @override
  Future<Either<Failure, List<MovieEntity>>> call({void params}) {
    return _likedMoviesRepository.getLikedMovies();
  }
}

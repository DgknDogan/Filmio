import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/movie.dart';
import '../repositories/liked_movies_repository.dart';

class DislikeMovieUseCase extends UseCase<Either<Failure, Unit>, MovieEntity> {
  final LikedMoviesRepository _likedMoviesRepository;

  DislikeMovieUseCase(this._likedMoviesRepository);

  @override
  Future<Either<Failure, Unit>> call({MovieEntity? params}) {
    return _likedMoviesRepository.dislikeMovie(movie: params!);
  }
}

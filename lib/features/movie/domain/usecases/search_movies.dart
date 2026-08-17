import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class SearchMoviesUseCase extends UseCase<Either<Failure, List<MovieEntity>>, String> {
  final MovieRepository _movieRepository;

  SearchMoviesUseCase(this._movieRepository);
  @override
  Future<Either<Failure, List<MovieEntity>>> call({String? params}) {
    return _movieRepository.searchMoviesByTitle(query: params!);
  }
}

import 'package:fpdart/fpdart.dart';

import '../../../../core/network/api_guard.dart';
import '../../../../core/resource/failure.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_api_service.dart';
import '../models/movie_api_response.dart';

class MovieRepositoryImpl extends MovieRepository {
  static const _language = "en-US";
  static const _firstPage = 1;

  final MovieApiService _movieApiService;

  MovieRepositoryImpl(this._movieApiService);

  @override
  Future<Either<Failure, List<MovieEntity>>> getPopularMovies() {
    return guardApiCall(
      () => _movieApiService.getPopularMovies(language: _language, page: _firstPage),
      _toEntities,
    );
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> getTopRatedMovies() {
    return guardApiCall(
      () => _movieApiService.getTopRatedMovies(language: _language, page: _firstPage),
      _toEntities,
    );
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> searchMoviesByTitle({required String query}) {
    return guardApiCall(
      () => _movieApiService.searchMoviesByTitle(
        query: query,
        language: _language,
        includeAdult: false,
        page: _firstPage,
      ),
      _toEntities,
    );
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> getSimilarMovies({required int movieId}) {
    return guardApiCall(
      () => _movieApiService.getSimilarMovies(movieId: movieId, language: _language, page: _firstPage),
      _toEntities,
    );
  }

  /// The single model → entity crossing for this feature.
  static List<MovieEntity> _toEntities(MovieApiResponse body) {
    return body.results?.map((model) => model.toEntity()).toList() ?? const [];
  }
}

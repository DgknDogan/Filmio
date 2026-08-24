import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/enums/discover_sort.dart';
import '../../../../core/enums/media_type.dart';
import '../../../../core/models/discover_filters.dart';
import '../../../../core/models/paginated_list.dart';
import '../../../../core/network/api_guard.dart';
import '../../../../core/network/discover_query.dart';
import '../../../../core/resource/failure.dart';
import '../../../../core/resource/failure_mapper.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_api_service.dart';
import '../models/movie_api_response.dart';

class MovieRepositoryImpl extends MovieRepository {
  static const _language = "en-US";
  static const _firstPage = 1;

  final MovieApiService _movieApiService;

  /// Only the recommendation service needs this: it authenticates as the user,
  /// not as the app.
  final FirebaseAuth _auth;

  MovieRepositoryImpl(this._movieApiService, this._auth);

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

  @override
  Future<Either<Failure, MovieEntity>> getMovieDetails({required int movieId}) {
    return guardApiCall(
      () => _movieApiService.getMovieDetails(movieId: movieId, language: _language),
      (body) => body.toEntity(),
    );
  }

  @override
  Future<Either<Failure, List<int>>> getRecommendedMovieIds({int? limit}) async {
    final user = _auth.currentUser;
    if (user == null) {
      return const Left(AuthFailure('Sign in to see what we would recommend.'));
    }

    try {
      final token = await user.getIdToken();
      if (token == null) {
        return const Left(AuthFailure('Could not verify your session. Sign in again.'));
      }

      return guardApiCall(
        () => _movieApiService.getRecommendations(authorization: 'Bearer $token', limit: limit),
        (body) => body.movieIds ?? const [],
      );
    } on FirebaseException catch (e) {
      return Left(failureFromFirebase(e));
    }
  }

  @override
  Future<Either<Failure, PaginatedList<MovieEntity>>> discoverMovies({
    required DiscoverFilters filters,
    required DiscoverSort sort,
    required int page,
  }) {
    return guardApiCall<PaginatedList<MovieEntity>, MovieApiResponse>(
      () => _movieApiService.discoverMovies(
        sortBy: DiscoverQuery.sortBy(sort),
        withGenres: DiscoverQuery.genres(filters),
        voteAverageGte: filters.minRating,
        voteAverageLte: filters.maxRating,
        voteCountGte: DiscoverQuery.voteCountFloor(sort, MediaType.movie),
        releaseDateGte: DiscoverQuery.fromYear(filters.minYear),
        releaseDateLte: DiscoverQuery.toYear(filters.maxYear),
        includeAdult: false,
        language: _language,
        page: page,
      ),
      (body) => _toPage(body, page),
    );
  }

  /// [requestedPage] stands in when TMDB leaves the envelope's numbers out: a
  /// page whose number defaulted to zero would read as "there is more" for
  /// ever, and the grid would never stop asking.
  static PaginatedList<MovieEntity> _toPage(MovieApiResponse body, int requestedPage) {
    final movies = _toEntities(body);
    final page = body.page ?? requestedPage;

    return PaginatedList(
      items: movies,
      page: page,
      totalPages: body.totalPages ?? page,
      totalResults: body.totalResults ?? movies.length,
    );
  }

  /// The single model → entity crossing for this feature.
  static List<MovieEntity> _toEntities(MovieApiResponse body) {
    return body.results?.map((model) => model.toEntity()).toList() ?? const [];
  }
}

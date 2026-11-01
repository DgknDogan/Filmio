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
import '../datasources/movie_recommendation_local_datasource.dart';
import '../models/movie_api_response.dart';

class MovieRepositoryImpl extends MovieRepository {
  static const _language = "en-US";
  static const _firstPage = 1;

  final MovieApiService _movieApiService;

  /// Only the recommendation service needs this: it authenticates as the user,
  /// not as the app.
  final FirebaseAuth _auth;

  /// Where the recommendation is kept between launches.
  final MovieRecommendationLocalDataSource _recommendationCache;

  MovieRepositoryImpl(this._movieApiService, this._auth, this._recommendationCache);

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

  /// Filmio's service names the ids, best first; TMDB tells us what each of
  /// them is. All of them are fetched — together, since none waits on another
  /// — and kept in the order the service ranked them.
  ///
  /// A title TMDB cannot answer for, or that the app cannot draw, is left out
  /// rather than sinking the rest. Only when none survives does this fail, and
  /// then with the best-ranked title's reason.
  ///
  /// The whole answer is cached, so the common case costs no requests at all.
  /// When the service cannot be reached and there is an entry too old to serve
  /// fresh, that entry is served anyway: a yesterday's recommendation reads
  /// better than an error where the tab's opening title should be.
  @override
  Future<Either<Failure, List<MovieEntity>>> getRecommendedMovies({int? limit}) async {
    // A guest is browsing without an account, which is a supported way to use
    // the app rather than something to report: there is nothing to recommend
    // from, so the caller falls back the same way it does for an account that
    // has liked nothing yet.
    final user = _auth.currentUser;
    if (user == null) return const Right([]);

    final cached = _recommendationCache.read(user.uid);
    if (cached != null) return Right(cached);

    final idsResult = await _recommendedMovieIds(user, limit: limit);

    return idsResult.fold(
      (failure) async => _stale(user.uid) ?? Left(failure),
      (movieIds) async {
        if (movieIds.isEmpty) {
          await _recommendationCache.write(user.uid, const []);
          return const Right([]);
        }

        final results = await Future.wait(movieIds.map((id) => getMovieDetails(movieId: id)));

        final movies = <MovieEntity>[];
        final failures = <Failure>[];
        for (final result in results) {
          result.fold(failures.add, (movie) {
            if (movie.isShowable) movies.add(movie);
          });
        }

        if (movies.isEmpty && failures.isNotEmpty) {
          return _stale(user.uid) ?? Left(failures.first);
        }

        await _recommendationCache.write(user.uid, movies);
        return Right(movies);
      },
    );
  }

  /// The cached recommendation regardless of its age, as a result, or null
  /// when there is nothing cached at all.
  Either<Failure, List<MovieEntity>>? _stale(String userId) {
    final stale = _recommendationCache.read(userId, ignoreAge: true);
    return stale == null ? null : Right(stale);
  }

  Future<Either<Failure, List<int>>> _recommendedMovieIds(User user, {int? limit}) async {
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

  /// The single model → entity crossing for this feature, and the one place a
  /// title the app cannot draw is dropped — see [MovieEntity.isShowable].
  static List<MovieEntity> _toEntities(MovieApiResponse body) {
    return body.results?.map((model) => model.toEntity()).where((movie) => movie.isShowable).toList() ?? const [];
  }
}

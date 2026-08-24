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
import '../../domain/entities/series_entity.dart';
import '../../domain/repositories/series_repository.dart';
import '../datasources/series_api_service.dart';
import '../models/series_api_response.dart';

class SeriesRepositoryImpl extends SeriesRepository {
  static const _language = "en-US";
  static const _firstPage = 1;

  final SeriesApiService _seriesApiService;

  /// Only the recommendation service needs this: it authenticates as the user,
  /// not as the app.
  final FirebaseAuth _auth;

  SeriesRepositoryImpl(this._seriesApiService, this._auth);

  @override
  Future<Either<Failure, List<SeriesEntity>>> getPopularSeries() {
    return guardApiCall(
      () => _seriesApiService.getPopularSeries(language: _language, page: _firstPage),
      _toEntities,
    );
  }

  @override
  Future<Either<Failure, List<SeriesEntity>>> getTopRatedSeries() {
    return guardApiCall(
      () => _seriesApiService.getTopRatedSeries(language: _language, page: _firstPage),
      _toEntities,
    );
  }

  @override
  Future<Either<Failure, List<SeriesEntity>>> searchSeries({required String query}) {
    return guardApiCall(
      () => _seriesApiService.searchMoviesByTitle(
        query: query,
        language: _language,
        includeAdult: false,
        page: _firstPage,
      ),
      _toEntities,
    );
  }

  @override
  Future<Either<Failure, List<SeriesEntity>>> getSimilarSeries({required int seriesId}) {
    return guardApiCall(
      () => _seriesApiService.getSimilarSeries(seriesId: seriesId, language: _language, page: _firstPage),
      _toEntities,
    );
  }

  @override
  Future<Either<Failure, SeriesEntity>> getSeriesDetails({required int seriesId}) {
    return guardApiCall(
      () => _seriesApiService.getSeriesDetails(seriesId: seriesId, language: _language),
      (body) => body.toEntity(),
    );
  }

  @override
  Future<Either<Failure, List<int>>> getRecommendedSeriesIds({int? limit}) async {
    // A guest is browsing without an account, which is a supported way to use
    // the app rather than something to report: there is nothing to recommend
    // from, so the caller falls back the same way it does for an account that
    // has liked nothing yet.
    final user = _auth.currentUser;
    if (user == null) return const Right([]);

    try {
      final token = await user.getIdToken();
      if (token == null) {
        return const Left(AuthFailure('Could not verify your session. Sign in again.'));
      }

      return guardApiCall(
        () => _seriesApiService.getRecommendations(authorization: 'Bearer $token', limit: limit),
        (body) => body.seriesIds ?? const [],
      );
    } on FirebaseException catch (e) {
      return Left(failureFromFirebase(e));
    }
  }

  @override
  Future<Either<Failure, PaginatedList<SeriesEntity>>> discoverSeries({
    required DiscoverFilters filters,
    required DiscoverSort sort,
    required int page,
  }) {
    return guardApiCall<PaginatedList<SeriesEntity>, SeriesApiResponse>(
      () => _seriesApiService.discoverSeries(
        sortBy: DiscoverQuery.sortBy(sort),
        withGenres: DiscoverQuery.genres(filters),
        voteAverageGte: filters.minRating,
        voteAverageLte: filters.maxRating,
        voteCountGte: DiscoverQuery.voteCountFloor(sort, MediaType.series),
        firstAirDateGte: DiscoverQuery.fromYear(filters.minYear),
        firstAirDateLte: DiscoverQuery.toYear(filters.maxYear),
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
  static PaginatedList<SeriesEntity> _toPage(SeriesApiResponse body, int requestedPage) {
    final series = _toEntities(body);
    final page = body.page ?? requestedPage;

    return PaginatedList(
      items: series,
      page: page,
      totalPages: body.totalPages ?? page,
      totalResults: body.totalResults ?? series.length,
    );
  }

  /// The single model → entity crossing for this feature.
  static List<SeriesEntity> _toEntities(SeriesApiResponse body) {
    return body.results?.map((model) => model.toEntity()).toList() ?? const [];
  }
}

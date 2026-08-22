import 'package:fpdart/fpdart.dart';

import '../../../../core/enums/media_type.dart';
import '../../../../core/models/paginated_list.dart';
import '../../../../core/network/api_guard.dart';
import '../../../../core/resource/failure.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_api_service.dart';
import '../models/review_api_response.dart';

class ReviewRepositoryImpl extends ReviewRepository {
  static const _language = "en-US";

  final ReviewApiService _reviewApiService;

  ReviewRepositoryImpl(this._reviewApiService);

  @override
  Future<Either<Failure, PaginatedList<ReviewEntity>>> getReviews({
    required int mediaId,
    required MediaType mediaType,
    required int page,
  }) {
    // The only thing the two catalogues disagree on is which endpoint to ask.
    final request = switch (mediaType) {
      MediaType.movie => () => _reviewApiService.getMovieReviews(movieId: mediaId, language: _language, page: page),
      MediaType.series => () => _reviewApiService.getSeriesReviews(seriesId: mediaId, language: _language, page: page),
    };

    return guardApiCall<PaginatedList<ReviewEntity>, ReviewApiResponse>(request, (body) => _toPage(body, page));
  }

  /// The single model → entity crossing for this feature.
  ///
  /// [requestedPage] stands in when TMDB leaves the envelope's numbers out:
  /// a page whose number defaulted to zero would read as "there is more" for
  /// ever, and the list would never stop asking.
  static PaginatedList<ReviewEntity> _toPage(ReviewApiResponse body, int requestedPage) {
    final reviews = body.results?.map((model) => model.toEntity()).toList() ?? const <ReviewEntity>[];
    final page = body.page ?? requestedPage;

    return PaginatedList(
      items: reviews,
      page: page,
      totalPages: body.totalPages ?? page,
      totalResults: body.totalResults ?? reviews.length,
    );
  }
}

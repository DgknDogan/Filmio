import 'package:fpdart/fpdart.dart';

import '../../../../core/enums/media_type.dart';
import '../../../../core/models/paginated_list.dart';
import '../../../../core/resource/failure.dart';
import '../entities/review_entity.dart';

abstract class ReviewRepository {
  /// One page of reviews for a film or a series. [page] is one-based.
  Future<Either<Failure, PaginatedList<ReviewEntity>>> getReviews({
    required int mediaId,
    required MediaType mediaType,
    required int page,
  });
}

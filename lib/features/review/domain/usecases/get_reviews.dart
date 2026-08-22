import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/enums/media_type.dart';
import '../../../../core/models/paginated_list.dart';
import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/review_entity.dart';
import '../repositories/review_repository.dart';

class GetReviewsParams extends Equatable {
  final int mediaId;
  final MediaType mediaType;

  /// One-based, as TMDB counts them.
  final int page;

  const GetReviewsParams({
    required this.mediaId,
    required this.mediaType,
    this.page = 1,
  });

  @override
  List<Object?> get props => [mediaId, mediaType, page];
}

class GetReviewsUseCase extends UseCase<Either<Failure, PaginatedList<ReviewEntity>>, GetReviewsParams> {
  final ReviewRepository _reviewRepository;

  GetReviewsUseCase(this._reviewRepository);

  @override
  Future<Either<Failure, PaginatedList<ReviewEntity>>> call({GetReviewsParams? params}) async {
    return await _reviewRepository.getReviews(
      mediaId: params!.mediaId,
      mediaType: params.mediaType,
      page: params.page,
    );
  }
}

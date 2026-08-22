import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/cubit/load_more_state.dart';
import '../../../../core/enums/media_type.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/usecases/get_reviews.dart';

part 'reviews_state.dart';

/// The reviews block on a details screen, for a film or a series alike.
///
/// It owns the paging: the widget says "there is more, go on" and this decides
/// which page that is. Pages are appended rather than replacing what is on
/// screen, so a failure part way down a list leaves the reviews already read
/// where they are.
class ReviewsCubit extends Cubit<ReviewsState> {
  static const _firstPage = 1;

  final GetReviewsUseCase _getReviewsUseCase;
  final int? _mediaId;
  final MediaType _mediaType;

  ReviewsCubit(
    this._getReviewsUseCase, {
    required int? mediaId,
    required MediaType mediaType,
  })  : _mediaId = mediaId,
        _mediaType = mediaType,
        super(const ReviewsLoading()) {
    loadFirstPage();
  }

  /// Also what the retry after a failed first page calls.
  Future<void> loadFirstPage() async {
    // TMDB addresses a title by id; without one there is nothing to ask for.
    if (_mediaId == null) {
      emit(const ReviewsLoaded(reviews: [], page: _firstPage, totalPages: _firstPage, totalResults: 0));
      return;
    }

    if (state is! ReviewsLoading) emit(const ReviewsLoading());

    final result = await _getReviewsUseCase.call(
      params: GetReviewsParams(mediaId: _mediaId, mediaType: _mediaType, page: _firstPage),
    );
    if (isClosed) return;

    result.fold(
      (failure) => emit(ReviewsFailure(failure.message)),
      (page) => emit(
        ReviewsLoaded(
          reviews: page.items,
          page: page.page,
          totalPages: page.totalPages,
          totalResults: page.totalResults,
        ),
      ),
    );
  }

  /// The next page, appended. Does nothing when the list is already complete
  /// or a page is in flight, so a second tap cannot ask for the same page
  /// twice.
  Future<void> loadMore() async {
    final current = state;
    if (current is! ReviewsLoaded) return;
    if (!current.hasMore || current.more is LoadMoreInProgress) return;
    if (_mediaId == null) return;

    emit(current.copyWith(more: const LoadMoreInProgress()));

    final nextPage = current.page + 1;
    final result = await _getReviewsUseCase.call(
      params: GetReviewsParams(mediaId: _mediaId, mediaType: _mediaType, page: nextPage),
    );
    if (isClosed) return;

    result.fold(
      // The reviews already on screen stay; only the foot of the list reports
      // that there was a problem, and offers to try again.
      (failure) => emit(current.copyWith(more: LoadMoreFailure(failure.message))),
      (page) => emit(
        ReviewsLoaded(
          reviews: [...current.reviews, ...page.items],
          page: page.page,
          totalPages: page.totalPages,
          totalResults: page.totalResults,
        ),
      ),
    );
  }
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/review_entity.dart';
import '../../domain/entities/review_report.dart';
import '../../domain/usecases/moderate_reviews.dart';

part 'review_moderation_state.dart';

/// What the reader has chosen not to see, and the two ways they choose it.
///
/// Separate from [ReviewsCubit] on purpose: that one owns paging, this one
/// owns moderation, and keeping them apart means blocking an author re-filters
/// the reviews already on screen instead of refetching a page to get rid of
/// one card.
class ReviewModerationCubit extends Cubit<ReviewModerationState> {
  final ReportReviewUseCase _reportReviewUseCase;
  final BlockReviewAuthorUseCase _blockReviewAuthorUseCase;
  final GetModerationUseCase _getModerationUseCase;

  ReviewModerationCubit(
    this._reportReviewUseCase,
    this._blockReviewAuthorUseCase,
    this._getModerationUseCase,
  ) : super(const ReviewModerationState()) {
    _load();
  }

  Future<void> _load() async {
    final moderation = await _getModerationUseCase.call();
    if (isClosed) return;

    emit(ReviewModerationState(
      blockedAuthors: moderation.blockedAuthors,
      hiddenReviewIds: moderation.hiddenReviewIds,
    ));
  }

  /// Files the report. Returns whether it was filed, so the card can say what
  /// happened either way — a report that silently failed is worse than none,
  /// because the reader stops looking for another way to complain.
  Future<bool> report(ReviewReport report) async {
    final result = await _reportReviewUseCase.call(params: report);
    if (isClosed) return false;

    return result.fold(
      (failure) => false,
      (_) {
        emit(state.copyWith(hiddenReviewIds: {...state.hiddenReviewIds, report.reviewId}));
        return true;
      },
    );
  }

  Future<void> blockAuthor(String author) async {
    final result = await _blockReviewAuthorUseCase.call(params: author);
    if (isClosed) return;

    result.fold(
      (failure) => null,
      (_) => emit(state.copyWith(blockedAuthors: {...state.blockedAuthors, author})),
    );
  }
}

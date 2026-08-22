part of 'reviews_cubit.dart';

/// A paged list has phases rather than flags — nothing on screen while the
/// first page is in flight, a message instead of the block if it fails, and
/// the list itself once it arrives — so this is sealed and the UI switches on
/// it exhaustively.
sealed class ReviewsState extends Equatable {
  const ReviewsState();

  @override
  List<Object?> get props => [];
}

final class ReviewsLoading extends ReviewsState {
  const ReviewsLoading();
}

/// The first page failed. Nothing is on screen to keep, so the whole block
/// reports it.
final class ReviewsFailure extends ReviewsState {
  final String message;

  const ReviewsFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Every page loaded so far, and where they end.
final class ReviewsLoaded extends ReviewsState {
  final List<ReviewEntity> reviews;

  /// The last page fetched, one-based.
  final int page;

  final int totalPages;

  /// Across every page — what a count in the heading should say, rather than
  /// `reviews.length`.
  final int totalResults;

  /// What the foot of the list is doing. Separate from the state itself:
  /// fetching page four is not the same as having nothing to show.
  final LoadMoreState more;

  const ReviewsLoaded({
    required this.reviews,
    required this.page,
    required this.totalPages,
    required this.totalResults,
    this.more = const LoadMoreIdle(),
  });

  bool get hasMore => page < totalPages;

  ReviewsLoaded copyWith({
    List<ReviewEntity>? reviews,
    int? page,
    int? totalPages,
    int? totalResults,
    LoadMoreState? more,
  }) {
    return ReviewsLoaded(
      reviews: reviews ?? this.reviews,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      totalResults: totalResults ?? this.totalResults,
      more: more ?? this.more,
    );
  }

  @override
  List<Object?> get props => [reviews, page, totalPages, totalResults, more];
}

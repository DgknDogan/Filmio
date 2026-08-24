part of 'review_moderation_cubit.dart';

/// Not a set of phases but a value: there is always an answer to "what is
/// hidden", even if it is "nothing".
final class ReviewModerationState extends Equatable {
  final Set<String> blockedAuthors;
  final Set<String> hiddenReviewIds;

  const ReviewModerationState({
    this.blockedAuthors = const {},
    this.hiddenReviewIds = const {},
  });

  /// [reviews] with everything the reader has hidden taken out. The list is
  /// filtered here rather than in the widget so the rule lives in one place
  /// and can be tested without pumping a tree.
  List<ReviewEntity> visible(List<ReviewEntity> reviews) {
    if (blockedAuthors.isEmpty && hiddenReviewIds.isEmpty) return reviews;

    return reviews.where((review) {
      if (review.id case final id? when hiddenReviewIds.contains(id)) return false;
      return !blockedAuthors.contains(review.displayName);
    }).toList();
  }

  ReviewModerationState copyWith({Set<String>? blockedAuthors, Set<String>? hiddenReviewIds}) {
    return ReviewModerationState(
      blockedAuthors: blockedAuthors ?? this.blockedAuthors,
      hiddenReviewIds: hiddenReviewIds ?? this.hiddenReviewIds,
    );
  }

  @override
  List<Object?> get props => [blockedAuthors, hiddenReviewIds];
}

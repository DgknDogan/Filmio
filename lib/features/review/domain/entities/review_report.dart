import 'package:equatable/equatable.dart';

import '../../../../core/enums/media_type.dart';

/// Why somebody is reporting a review.
///
/// A fixed list rather than free text: it is faster to answer, and it makes
/// the reports sortable when somebody has to work through them.
enum ReportReason {
  offensiveLanguage,
  hateOrHarassment,
  spam,
  spoiler,
  other;
}

/// One report of one review, as it is filed.
///
/// The excerpt travels with it because TMDB reviews can be edited or removed
/// upstream: without a copy of what was actually on screen, a report can
/// become unactionable by the time anyone reads it.
class ReviewReport extends Equatable {
  final String reviewId;
  final String author;
  final int mediaId;
  final MediaType mediaType;
  final ReportReason reason;
  final String excerpt;

  const ReviewReport({
    required this.reviewId,
    required this.author,
    required this.mediaId,
    required this.mediaType,
    required this.reason,
    required this.excerpt,
  });

  @override
  List<Object?> get props => [reviewId, author, mediaId, mediaType, reason, excerpt];
}

import 'package:equatable/equatable.dart';

import '../../../../core/utils/content_filter.dart';

/// One review of a film or a series.
///
/// TMDB nests the author's name, handle, avatar and score under
/// `author_details`; they are flat here because nothing reads them apart from
/// the line at the top of a review card, and a second entity for four fields
/// would only be a second file to open.
class ReviewEntity extends Equatable {
  final String? id;

  /// The handle TMDB credits the review to.
  final String? author;

  /// The author's own display name, which is often empty even when [author]
  /// is not.
  final String? authorName;

  final String? authorUsername;

  /// Either a TMDB path (`/abc.jpg`) or a full Gravatar URL behind a leading
  /// slash. `String.avatarImage` is what resolves the two.
  final String? avatarPath;

  /// Out of 10, and absent for a review left without a score.
  final double? rating;

  final String? content;

  /// ISO 8601, as sent.
  final String? createdAt;
  final String? updatedAt;

  final String? url;

  const ReviewEntity({
    this.id,
    this.author,
    this.authorName,
    this.authorUsername,
    this.avatarPath,
    this.rating,
    this.content,
    this.createdAt,
    this.updatedAt,
    this.url,
  });

  /// What to credit the review to: the name if there is one, the handle
  /// otherwise. Both are optional on TMDB's side, so this can still be empty.
  String get displayName {
    for (final candidate in [authorName, author, authorUsername]) {
      if (candidate != null && candidate.trim().isNotEmpty) return candidate.trim();
    }
    return '';
  }

  /// Whether the review reads as something to warn about before showing.
  ///
  /// A property of the text, so it is computed here next to [displayName]
  /// rather than carried as a field somebody has to remember to set. The card
  /// folds a flagged review behind a warning instead of dropping it — the
  /// reader decides, which is the difference between filtering and censoring.
  bool get isObjectionable => ContentFilter.isObjectionable(content);

  @override
  List<Object?> get props => [
        id,
        author,
        authorName,
        authorUsername,
        avatarPath,
        rating,
        content,
        createdAt,
        updatedAt,
        url,
      ];
}

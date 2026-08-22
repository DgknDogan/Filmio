import 'package:equatable/equatable.dart';

/// One page of a list the server hands out in pages, plus where that page sits
/// in the whole.
///
/// Shared rather than written per feature: TMDB pages every collection it
/// returns the same way, and a screen that loads more needs the same three
/// numbers whatever it is listing.
class PaginatedList<T> extends Equatable {
  /// What this page carries — not the whole collection.
  final List<T> items;

  /// One-based, as TMDB counts them.
  final int page;

  final int totalPages;

  /// Across every page, which is what a count in the UI should say.
  final int totalResults;

  const PaginatedList({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalResults,
  });

  /// Whether asking for the page after this one would return anything.
  bool get hasMore => page < totalPages;

  @override
  List<Object?> get props => [items, page, totalPages, totalResults];
}

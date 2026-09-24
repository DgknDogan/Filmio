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

  /// The most TMDB will ever admit to having: it stops counting at 20,001
  /// results across 1,001 pages and answers with that ceiling for anything
  /// larger, whatever was asked for.
  ///
  /// Which is why the browse screen's count looked stuck — a genre or a year
  /// narrows the catalogue from unimaginably many to merely very many, and
  /// both come back as the same number.
  static const countCeiling = 20001;

  /// Whether [totalResults] is that ceiling rather than a count.
  bool get isCountCapped => totalResults >= countCeiling;

  /// Whether asking for the page after this one would return anything.
  bool get hasMore => page < totalPages;

  @override
  List<Object?> get props => [items, page, totalPages, totalResults];
}

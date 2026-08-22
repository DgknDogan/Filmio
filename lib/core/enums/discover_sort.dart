/// The order a browsed catalogue comes back in.
///
/// Only the two the app opens a list on. TMDB's `sort_by` carries a dozen more
/// and each repository maps to its own strings — the domain names the order,
/// not the query.
enum DiscoverSort {
  /// What the home row calls popular.
  popularity,

  /// Highest rated, among titles with enough votes to mean anything.
  topRated,
}

/// Which of the two catalogues a title belongs to.
///
/// TMDB keeps films and television apart in the path but hands back the same
/// record for both — a review is the same shape either way — so anything that
/// works on both takes one of these instead of a flag or a path string.
enum MediaType { movie, series }

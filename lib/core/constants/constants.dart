/// Prefix for TMDB poster and backdrop paths.
const imagePathUrl = "https://image.tmdb.org/t/p/original";

/// Where YouTube keeps the still for a video: `<base>/<video key>/hqdefault.jpg`.
/// TMDB gives the key but no thumbnail, and YouTube publishes one for every
/// video at this address.
const youtubeThumbnailBaseUrl = "https://img.youtube.com/vi";

/// Where a YouTube video is watched: `<base>?v=<video key>`. On iOS and
/// Android this address opens the YouTube app when it is installed and the
/// browser when it is not, which is why the app builds a link rather than
/// naming an app-specific scheme.
const youtubeWatchUrl = "https://www.youtube.com/watch";

/// Base URL for every TMDB endpoint the app calls.
const tmdbBaseUrl = "https://api.themoviedb.org/3";

/// Firestore collection holding one document per user.
const userCollection = "User";

/// Firestore collection every reported review lands in. It is a moderation
/// queue for a person to read — nothing in the app reads it back.
const reviewReportCollection = "ReviewReport";

/// Base URL of Filmio's own recommendation service, which picks titles from
/// what the signed-in user has liked. Unlike TMDB it authenticates with the
/// user's Firebase ID token, so calls against it carry their own header.
const recommendationBaseUrl = "https://filmio-api-640047605009.europe-west1.run.app";

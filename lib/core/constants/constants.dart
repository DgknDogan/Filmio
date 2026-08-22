/// Prefix for TMDB poster and backdrop paths.
const imagePathUrl = "https://image.tmdb.org/t/p/original";

/// Where YouTube keeps the still for a video: `<base>/<video key>/hqdefault.jpg`.
/// TMDB gives the key but no thumbnail, and YouTube publishes one for every
/// video at this address.
const youtubeThumbnailBaseUrl = "https://img.youtube.com/vi";

/// Base URL for every TMDB endpoint the app calls.
const tmdbBaseUrl = "https://api.themoviedb.org/3";

/// Firestore collection holding one document per user.
const userCollection = "User";

import 'package:filmio/core/enums/media_type.dart';
import 'package:filmio/features/auth/domain/repositories/auth_repository.dart';
import 'package:filmio/features/auth/domain/usecases/is_profile_complete.dart';
import 'package:filmio/features/auth/domain/usecases/login.dart';
import 'package:filmio/features/auth/domain/usecases/logout.dart';
import 'package:filmio/features/auth/domain/usecases/register.dart';
import 'package:filmio/features/auth/domain/usecases/restore_session.dart';
import 'package:filmio/features/auth/domain/usecases/update_profile.dart';
import 'package:filmio/features/movie/data/datasources/movie_api_service.dart';
import 'package:filmio/features/movie/domain/entities/movie.dart';
import 'package:filmio/features/movie/domain/repositories/liked_movies_repository.dart';
import 'package:filmio/features/movie/domain/repositories/movie_repository.dart';
import 'package:filmio/features/movie/domain/usecases/discover_movies.dart';
import 'package:filmio/features/movie/domain/usecases/dislike_movie.dart';
import 'package:filmio/features/movie/domain/usecases/get_liked_movies.dart';
import 'package:filmio/features/movie/domain/usecases/get_popular_movies.dart';
import 'package:filmio/features/movie/domain/usecases/get_similar_movies.dart';
import 'package:filmio/features/movie/domain/usecases/get_top_rated_movies.dart';
import 'package:filmio/features/movie/domain/usecases/like_movie.dart';
import 'package:filmio/features/movie/domain/usecases/search_movies.dart';
import 'package:filmio/features/review/data/datasources/review_api_service.dart';
import 'package:filmio/features/review/domain/repositories/review_repository.dart';
import 'package:filmio/features/review/domain/usecases/get_reviews.dart';
import 'package:filmio/features/series/data/datasources/series_api_service.dart';
import 'package:filmio/features/series/domain/entities/series_entity.dart';
import 'package:filmio/features/series/domain/repositories/liked_series_repository.dart';
import 'package:filmio/features/series/domain/repositories/series_repository.dart';
import 'package:filmio/features/series/domain/usecases/discover_series.dart';
import 'package:filmio/features/series/domain/usecases/dislike_series.dart';
import 'package:filmio/features/series/domain/usecases/get_liked_series.dart';
import 'package:filmio/features/series/domain/usecases/get_popular_series.dart';
import 'package:filmio/features/series/domain/usecases/get_similar_series.dart';
import 'package:filmio/features/series/domain/usecases/get_top_rated_series.dart';
import 'package:filmio/features/series/domain/usecases/like_series.dart';
import 'package:filmio/features/series/domain/usecases/search_series.dart';
import 'package:filmio/features/video/data/datasources/video_api_service.dart';
import 'package:filmio/features/video/domain/repositories/video_repository.dart';
import 'package:filmio/features/video/domain/usecases/get_trailer.dart';
import 'package:mocktail/mocktail.dart';

// Use cases — what a cubit or bloc collaborates with.
class MockGetPopularMoviesUseCase extends Mock implements GetPopularMoviesUseCase {}

class MockGetTopRatedMoviesUseCase extends Mock implements GetTopRatedMoviesUseCase {}

class MockSearchMoviesUseCase extends Mock implements SearchMoviesUseCase {}

class MockGetSimilarMoviesUseCase extends Mock implements GetSimilarMoviesUseCase {}

class MockDiscoverMoviesUseCase extends Mock implements DiscoverMoviesUseCase {}

class MockGetLikedMoviesUseCase extends Mock implements GetLikedMoviesUseCase {}

class MockLikeMovieUseCase extends Mock implements LikeMovieUseCase {}

class MockDislikeMovieUseCase extends Mock implements DislikeMovieUseCase {}

class MockGetPopularSeriesUseCase extends Mock implements GetPopularSeriesUseCase {}

class MockGetTopRatedSeriesUseCase extends Mock implements GetTopRatedSeriesUseCase {}

class MockSearchSeriesUseCase extends Mock implements SearchSeriesUseCase {}

class MockGetSimilarSeriesUseCase extends Mock implements GetSimilarSeriesUseCase {}

class MockDiscoverSeriesUseCase extends Mock implements DiscoverSeriesUseCase {}

class MockGetLikedSeriesUseCase extends Mock implements GetLikedSeriesUseCase {}

class MockLikeSeriesUseCase extends Mock implements LikeSeriesUseCase {}

class MockDislikeSeriesUseCase extends Mock implements DislikeSeriesUseCase {}

class MockGetReviewsUseCase extends Mock implements GetReviewsUseCase {}

class MockGetTrailerUseCase extends Mock implements GetTrailerUseCase {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockRestoreSessionUseCase extends Mock implements RestoreSessionUseCase {}

class MockIsProfileCompleteUseCase extends Mock implements IsProfileCompleteUseCase {}

class MockUpdateDisplayNameUseCase extends Mock implements UpdateDisplayNameUseCase {}

class MockUpdateProfilePhotoUseCase extends Mock implements UpdateProfilePhotoUseCase {}

class MockGetProfilePhotoUseCase extends Mock implements GetProfilePhotoUseCase {}

// Repositories and services — what a repository or use case collaborates with.
class MockMovieRepository extends Mock implements MovieRepository {}

class MockLikedMoviesRepository extends Mock implements LikedMoviesRepository {}

class MockLikedSeriesRepository extends Mock implements LikedSeriesRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockMovieApiService extends Mock implements MovieApiService {}

class MockSeriesApiService extends Mock implements SeriesApiService {}

class MockSeriesRepository extends Mock implements SeriesRepository {}

class MockReviewApiService extends Mock implements ReviewApiService {}

class MockReviewRepository extends Mock implements ReviewRepository {}

class MockVideoApiService extends Mock implements VideoApiService {}

class MockVideoRepository extends Mock implements VideoRepository {}

/// Registers the values `any()` needs to construct when it stands in for a
/// non-nullable argument. Call once per test file, in `setUpAll`.
void registerCommonFallbacks() {
  registerFallbackValue(MediaType.movie);
  registerFallbackValue(const MovieEntity());
  registerFallbackValue(const SeriesEntity());
  registerFallbackValue(LoginParams(email: '', password: ''));
  registerFallbackValue(RegisterParams(email: '', password: ''));
  registerFallbackValue(const GetReviewsParams(mediaId: 0, mediaType: MediaType.movie));
  registerFallbackValue(const GetTrailerParams(mediaId: 0, mediaType: MediaType.movie));
  registerFallbackValue(const DiscoverMoviesParams());
  registerFallbackValue(const DiscoverSeriesParams());
}

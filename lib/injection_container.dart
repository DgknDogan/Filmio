import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/theme/cubit/theme_cubit.dart';
import 'core/network/dio_client.dart';
import 'core/storage/theme_local_datasource.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/is_profile_complete.dart';
import 'features/auth/domain/usecases/login.dart';
import 'features/auth/domain/usecases/logout.dart';
import 'features/auth/domain/usecases/register.dart';
import 'features/auth/domain/usecases/restore_session.dart';
import 'features/auth/domain/usecases/update_profile.dart';
import 'features/auth/presentation/cubit/login_cubit.dart';
import 'features/landing/presentation/cubit/splash_cubit.dart';
import 'features/movie/data/datasources/movie_api_service.dart';
import 'features/movie/data/repositories/liked_movies_repository_impl.dart';
import 'features/movie/data/repositories/movie_repository_impl.dart';
import 'features/movie/domain/repositories/liked_movies_repository.dart';
import 'features/movie/domain/repositories/movie_repository.dart';
import 'features/movie/domain/usecases/dislike_movie.dart';
import 'features/movie/domain/usecases/get_liked_movies.dart';
import 'features/movie/domain/usecases/get_popular_movies.dart';
import 'features/movie/domain/usecases/get_similar_movies.dart';
import 'features/movie/domain/usecases/get_top_rated_movies.dart';
import 'features/movie/domain/usecases/like_movie.dart';
import 'features/movie/domain/usecases/search_movies.dart';
import 'features/series/data/datasources/series_api_service.dart';
import 'features/series/data/repositories/liked_series_repository_impl.dart';
import 'features/series/data/repositories/series_repository_impl.dart';
import 'features/series/domain/repositories/liked_series_repository.dart';
import 'features/series/domain/repositories/series_repository.dart';
import 'features/series/domain/usecases/dislike_series.dart';
import 'features/series/domain/usecases/get_liked_series.dart';
import 'features/series/domain/usecases/get_popular_series.dart';
import 'features/series/domain/usecases/get_similar_series.dart';
import 'features/series/domain/usecases/get_top_rated_series.dart';
import 'features/series/domain/usecases/like_series.dart';
import 'features/series/domain/usecases/search_series.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  // Dio — carries the TMDB credentials for every service that shares it.
  getIt.registerSingleton<Dio>(buildTmdbDio());

  // Shared Preferences
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Firebase — registered so repositories take them by constructor and stay mockable.
  getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);

  // Dependencies
  getIt.registerSingleton<MovieApiService>(MovieApiService(getIt()));
  getIt.registerSingleton<MovieRepository>(MovieRepositoryImpl(getIt()));

  getIt.registerSingleton<LikedMoviesRepository>(LikedMoviesRepositoryImpl(getIt(), getIt()));

  getIt.registerSingleton<SeriesApiService>(SeriesApiService(getIt()));
  getIt.registerSingleton<SeriesRepository>(SeriesRepositoryImpl(getIt()));

  getIt.registerSingleton<LikedSeriesRepository>(LikedSeriesRepositoryImpl(getIt(), getIt()));

  getIt.registerSingleton<ThemeLocalDataSource>(ThemeLocalDataSource(sharedPreferences));
  getIt.registerSingleton<AuthLocalDataSource>(AuthLocalDataSource(sharedPreferences));
  getIt.registerSingleton<AuthRepository>(AuthRepositoryImpl(getIt(), getIt(), getIt()));

  // Earlier builds stored the e-mail and password in plaintext. Delete them
  // once, on the first launch after this version.
  await getIt<AuthLocalDataSource>().purgeLegacyCredentials();

  // Use Cases
  getIt.registerSingleton<GetTopRatedMoviesUseCase>(GetTopRatedMoviesUseCase(getIt()));
  getIt.registerSingleton<GetPopularMoviesUseCase>(GetPopularMoviesUseCase(getIt()));
  getIt.registerSingleton<GetLikedMoviesUseCase>(GetLikedMoviesUseCase(getIt()));
  getIt.registerSingleton<LikeMovieUseCase>(LikeMovieUseCase(getIt()));
  getIt.registerSingleton<DislikeMovieUseCase>(DislikeMovieUseCase(getIt()));
  getIt.registerSingleton<SearchMoviesUseCase>(SearchMoviesUseCase(getIt()));
  getIt.registerSingleton<GetSimilarMoviesUseCase>(GetSimilarMoviesUseCase(getIt()));
  getIt.registerSingleton<SearchSeriesUseCase>(SearchSeriesUseCase(getIt()));

  getIt.registerSingleton<GetTopRatedSeriesUseCase>(GetTopRatedSeriesUseCase(getIt()));
  getIt.registerSingleton<GetPopularSeriesUseCase>(GetPopularSeriesUseCase(getIt()));
  getIt.registerSingleton<GetSimilarSeriesUseCase>(GetSimilarSeriesUseCase(getIt()));
  getIt.registerSingleton<GetLikedSeriesUseCase>(GetLikedSeriesUseCase(getIt()));
  getIt.registerSingleton<LikeSeriesUseCase>(LikeSeriesUseCase(getIt()));
  getIt.registerSingleton<DislikeSeriesUseCase>(DislikeSeriesUseCase(getIt()));

  getIt.registerSingleton<LoginUseCase>(LoginUseCase(getIt()));
  getIt.registerSingleton<RegisterUseCase>(RegisterUseCase(getIt()));
  getIt.registerSingleton<LogoutUseCase>(LogoutUseCase(getIt()));
  getIt.registerSingleton<RestoreSessionUseCase>(RestoreSessionUseCase(getIt()));
  getIt.registerSingleton<IsProfileCompleteUseCase>(IsProfileCompleteUseCase(getIt()));
  getIt.registerSingleton<UpdateDisplayNameUseCase>(UpdateDisplayNameUseCase(getIt()));
  getIt.registerSingleton<UpdateProfilePhotoUseCase>(UpdateProfilePhotoUseCase(getIt()));
  getIt.registerSingleton<GetProfilePhotoUseCase>(GetProfilePhotoUseCase(getIt()));
  getIt.registerSingleton<GetProfileUseCase>(GetProfileUseCase(getIt()));

  // Cubit
  getIt.registerFactory<LoginCubit>(() => LoginCubit(getIt(), getIt()));
  getIt.registerFactory<SplashCubit>(() => SplashCubit(getIt()));
  getIt.registerFactory<ThemeCubit>(() => ThemeCubit(getIt()));
}

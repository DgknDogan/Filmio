import 'package:dio/dio.dart';

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/auth/cubit/login_cubit.dart';
import 'features/movie/data/data_sources/firebase/firebase_service.dart';
import 'features/movie/data/data_sources/remote/movie_api_service.dart';
import 'features/movie/data/repository/firebase_repository_impl.dart';
import 'features/movie/data/repository/movie_repository_impl.dart';
import 'features/movie/domain/repository/firebase_repository.dart';
import 'features/movie/domain/repository/movie_repository.dart';
import 'features/movie/domain/usecases/dislike_movie.dart';
import 'features/movie/domain/usecases/get_liked_movies.dart';
import 'features/movie/domain/usecases/get_popular_movies.dart';
import 'features/movie/domain/usecases/get_top_rated_movies.dart';
import 'features/movie/domain/usecases/like_movie.dart';
import 'features/series/data/data_sources/remote/series_api_service.dart';
import 'features/series/data/repository/series_repository_impl.dart';
import 'features/series/domain/repository/series_repository.dart';
import 'features/series/domain/usecases/get_popular_series.dart';
import 'features/series/domain/usecases/get_top_rated_series.dart';

final getIt = GetIt.instance;

void initDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  // Dio
  getIt.registerSingleton<Dio>(Dio());

  // Shared Preferences
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Dependencies
  getIt.registerSingleton<MovieApiService>(MovieApiService(getIt()));
  getIt.registerSingleton<MovieRepository>(MovieRepositoryImpl(getIt()));

  getIt.registerSingleton<FirebaseService>(FirebaseService());
  getIt.registerSingleton<FirebaseRepository>(FirebaseRepositoryImpl(getIt()));

  getIt.registerSingleton<SeriesApiService>(SeriesApiService(getIt()));
  getIt.registerSingleton<SeriesRepository>(SeriesRepositoryImpl(getIt()));

  // Use Cases
  getIt.registerSingleton<GetTopRatedMoviesUseCase>(GetTopRatedMoviesUseCase(getIt()));
  getIt.registerSingleton<GetPopularMoviesUseCase>(GetPopularMoviesUseCase(getIt()));
  getIt.registerSingleton<GetLikedMoviesUseCase>(GetLikedMoviesUseCase(getIt()));
  getIt.registerSingleton<LikeMovieUseCase>(LikeMovieUseCase(getIt()));
  getIt.registerSingleton<DislikeMovieUseCase>(DislikeMovieUseCase(getIt()));

  getIt.registerSingleton<GetTopRatedSeriesUseCase>(GetTopRatedSeriesUseCase(getIt()));
  getIt.registerSingleton<GetPopularSeriesUseCase>(GetPopularSeriesUseCase(getIt()));

  // Cubit
  getIt.registerSingleton<LoginCubit>(LoginCubit());
}

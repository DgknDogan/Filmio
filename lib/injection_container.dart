import 'package:dio/dio.dart';

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/auth/data/repository/auth_repository_impl.dart';
import 'features/auth/domain/repository/auth_repository.dart';
import 'features/auth/domain/usecase/login.dart';
import 'features/auth/domain/usecase/logout.dart';
import 'features/auth/domain/usecase/register.dart';
import 'features/auth/presentation/cubit/login_cubit.dart';
import 'features/movie/data/data_sources/remote/movie_api_service.dart';
import 'features/movie/data/repository/firebase_repository_impl.dart';
import 'features/movie/data/repository/movie_repository_impl.dart';
import 'features/movie/domain/repository/firebase_repository.dart';
import 'features/movie/domain/repository/movie_repository.dart';
import 'features/movie/domain/usecases/dislike_movie.dart';
import 'features/movie/domain/usecases/get_liked_movies.dart';
import 'features/movie/domain/usecases/get_popular_movies.dart';
import 'features/movie/domain/usecases/get_similar_movies.dart';
import 'features/movie/domain/usecases/get_top_rated_movies.dart';
import 'features/movie/domain/usecases/like_movie.dart';
import 'features/movie/domain/usecases/search_movies.dart';
import 'features/series/data/data_sources/remote/series_api_service.dart';
import 'features/series/data/repository/series_repository_impl.dart';
import 'features/series/domain/repository/series_repository.dart';
import 'features/series/domain/usecases/get_popular_series.dart';
import 'features/series/domain/usecases/get_top_rated_series.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  // Dio
  getIt.registerSingleton<Dio>(Dio());

  // Shared Preferences
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Dependencies
  getIt.registerSingleton<MovieApiService>(MovieApiService(getIt()));
  getIt.registerSingleton<MovieRepository>(MovieRepositoryImpl(getIt()));

  getIt.registerSingleton<FirebaseRepository>(FirebaseRepositoryImpl());

  getIt.registerSingleton<SeriesApiService>(SeriesApiService(getIt()));
  getIt.registerSingleton<SeriesRepository>(SeriesRepositoryImpl(getIt()));

  getIt.registerSingleton<AuthRepository>(AuthRepositoryImpl());

  // Use Cases
  getIt.registerSingleton<GetTopRatedMoviesUseCase>(GetTopRatedMoviesUseCase(getIt()));
  getIt.registerSingleton<GetPopularMoviesUseCase>(GetPopularMoviesUseCase(getIt()));
  getIt.registerSingleton<GetLikedMoviesUseCase>(GetLikedMoviesUseCase(getIt()));
  getIt.registerSingleton<LikeMovieUseCase>(LikeMovieUseCase(getIt()));
  getIt.registerSingleton<DislikeMovieUseCase>(DislikeMovieUseCase(getIt()));
  getIt.registerSingleton<SearchMoviesUseCase>(SearchMoviesUseCase(getIt()));
  getIt.registerSingleton<GetSimilarMoviesUseCase>(GetSimilarMoviesUseCase(getIt()));

  getIt.registerSingleton<GetTopRatedSeriesUseCase>(GetTopRatedSeriesUseCase(getIt()));
  getIt.registerSingleton<GetPopularSeriesUseCase>(GetPopularSeriesUseCase(getIt()));

  getIt.registerSingleton<LoginUseCase>(LoginUseCase(getIt()));
  getIt.registerSingleton<RegisterUseCase>(RegisterUseCase(getIt()));
  getIt.registerSingleton<LogoutUseCase>(LogoutUseCase(getIt()));

  // Cubit
  getIt.registerFactory<LoginCubit>(() => LoginCubit(getIt()));
}

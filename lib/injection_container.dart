import 'package:dio/dio.dart';
import 'package:filmio/features/movie/domain/usecases/dislike_movie.dart';

import 'package:get_it/get_it.dart';

import 'features/movie/data/data_sources/firebase/firebase_service.dart';
import 'features/movie/data/data_sources/remote/movie_api_service.dart';
import 'features/movie/data/repository/firebase_repository_impl.dart';
import 'features/movie/data/repository/movie_repository_impl.dart';
import 'features/movie/domain/repository/firebase_repository.dart';
import 'features/movie/domain/repository/movie_repository.dart';
import 'features/movie/domain/usecases/get_liked_movies.dart';
import 'features/movie/domain/usecases/get_popular_movies.dart';
import 'features/movie/domain/usecases/get_top_rated_movies.dart';
import 'features/movie/domain/usecases/like_movie.dart';

final getIt = GetIt.instance;

void initDependencies() async {
  // Dio
  getIt.registerSingleton<Dio>(Dio());

  // Dependencies
  getIt.registerSingleton<MovieApiService>(MovieApiService(getIt()));
  getIt.registerSingleton<MovieRepository>(MovieRepositoryImpl(getIt()));

  getIt.registerSingleton<FirebaseService>(FirebaseService());
  getIt.registerSingleton<FirebaseRepository>(FirebaseRepositoryImpl(getIt()));

  // Use Cases
  getIt.registerSingleton<GetTopRatedMoviesUseCase>(GetTopRatedMoviesUseCase(getIt()));
  getIt.registerSingleton<GetPopularMoviesUseCase>(GetPopularMoviesUseCase(getIt()));
  getIt.registerSingleton<GetLikedMoviesUseCase>(GetLikedMoviesUseCase(getIt()));
  getIt.registerSingleton<LikeMovieUseCase>(LikeMovieUseCase(getIt()));
  getIt.registerSingleton<DislikeMovieUseCase>(DislikeMovieUseCase(getIt()));
}

import 'package:dio/dio.dart';
import 'package:filmio/features/movie/data/repository/movie_repository_impl.dart';
import 'package:filmio/features/movie/domain/usecases/get_top_rated_movies.dart';
import 'package:get_it/get_it.dart';

import 'features/movie/data/data_sources/remote/movie_api_service.dart';
import 'features/movie/domain/repository/movie_repository.dart';
import 'features/movie/domain/usecases/get_popular_movies.dart';

final getIt = GetIt.instance;

void initDependencies() async {
  // Dio
  getIt.registerSingleton<Dio>(Dio());

  // Dependencies
  getIt.registerSingleton<MovieApiService>(MovieApiService(getIt()));

  getIt.registerSingleton<MovieRepository>(MovieRepositoryImpl(getIt()));

  // Use Cases
  getIt.registerSingleton<GetTopRatedMoviesUseCase>(GetTopRatedMoviesUseCase(getIt()));
  getIt.registerSingleton<GetPopularMoviesUseCase>(GetPopularMoviesUseCase(getIt()));
}

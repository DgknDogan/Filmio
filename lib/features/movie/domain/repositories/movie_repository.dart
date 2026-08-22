import 'package:fpdart/fpdart.dart';

import '../../../../core/enums/discover_sort.dart';
import '../../../../core/models/discover_filters.dart';
import '../../../../core/models/paginated_list.dart';
import '../../../../core/resource/failure.dart';
import '../entities/movie.dart';

abstract class MovieRepository {
  Future<Either<Failure, List<MovieEntity>>> getPopularMovies();
  Future<Either<Failure, List<MovieEntity>>> getTopRatedMovies();
  Future<Either<Failure, List<MovieEntity>>> searchMoviesByTitle({required String query});
  Future<Either<Failure, List<MovieEntity>>> getSimilarMovies({required int movieId});

  /// One page of the catalogue, in [sort] order, narrowed by [filters].
  /// [page] is one-based.
  Future<Either<Failure, PaginatedList<MovieEntity>>> discoverMovies({
    required DiscoverFilters filters,
    required DiscoverSort sort,
    required int page,
  });
}

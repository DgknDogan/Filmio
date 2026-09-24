import 'package:fpdart/fpdart.dart';

import '../../../../core/enums/discover_sort.dart';
import '../../../../core/models/discover_filters.dart';
import '../../../../core/models/paginated_list.dart';
import '../../../../core/resource/failure.dart';
import '../entities/series_entity.dart';

abstract class SeriesRepository {
  Future<Either<Failure, List<SeriesEntity>>> getPopularSeries();
  Future<Either<Failure, List<SeriesEntity>>> getTopRatedSeries();
  Future<Either<Failure, List<SeriesEntity>>> searchSeries({required String query});
  Future<Either<Failure, List<SeriesEntity>>> getSimilarSeries({required int seriesId});

  /// One series in full, by its TMDB id.
  Future<Either<Failure, SeriesEntity>> getSeriesDetails({required int seriesId});

  /// The titles Filmio's recommendation service picks for the signed-in user,
  /// best first.
  ///
  /// The service names ids; this answers with the titles themselves, because
  /// the two are one question to everybody who asks it and turning one into
  /// the other costs a request per title. Answered from a cache where there is
  /// a recent one, which is the point of keeping the whole thing behind a
  /// single method.
  ///
  /// Empty when there is nothing to go on — the service had too little to work
  /// with, or nobody is signed in at all. Browsing as a guest is not a failure.
  ///
  /// [limit] overrides the count the service would choose by itself.
  Future<Either<Failure, List<SeriesEntity>>> getRecommendedSeries({int? limit});

  /// One page of the catalogue, in [sort] order, narrowed by [filters].
  /// [page] is one-based.
  Future<Either<Failure, PaginatedList<SeriesEntity>>> discoverSeries({
    required DiscoverFilters filters,
    required DiscoverSort sort,
    required int page,
  });
}

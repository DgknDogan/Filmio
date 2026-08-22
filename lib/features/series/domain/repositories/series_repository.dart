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

  /// One page of the catalogue, in [sort] order, narrowed by [filters].
  /// [page] is one-based.
  Future<Either<Failure, PaginatedList<SeriesEntity>>> discoverSeries({
    required DiscoverFilters filters,
    required DiscoverSort sort,
    required int page,
  });
}

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/enums/discover_sort.dart';
import '../../../../core/models/discover_filters.dart';
import '../../../../core/models/paginated_list.dart';
import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/series_entity.dart';
import '../repositories/series_repository.dart';

class DiscoverSeriesParams extends Equatable {
  final DiscoverFilters filters;
  final DiscoverSort sort;

  /// One-based, as TMDB counts them.
  final int page;

  const DiscoverSeriesParams({
    this.filters = DiscoverFilters.none,
    this.sort = DiscoverSort.popularity,
    this.page = 1,
  });

  @override
  List<Object?> get props => [filters, sort, page];
}

class DiscoverSeriesUseCase extends UseCase<Either<Failure, PaginatedList<SeriesEntity>>, DiscoverSeriesParams> {
  final SeriesRepository _seriesRepository;

  DiscoverSeriesUseCase(this._seriesRepository);

  @override
  Future<Either<Failure, PaginatedList<SeriesEntity>>> call({DiscoverSeriesParams? params}) async {
    return await _seriesRepository.discoverSeries(
      filters: params!.filters,
      sort: params.sort,
      page: params.page,
    );
  }
}

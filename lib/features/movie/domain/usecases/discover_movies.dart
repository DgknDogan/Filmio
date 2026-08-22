import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/enums/discover_sort.dart';
import '../../../../core/models/discover_filters.dart';
import '../../../../core/models/paginated_list.dart';
import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class DiscoverMoviesParams extends Equatable {
  final DiscoverFilters filters;
  final DiscoverSort sort;

  /// One-based, as TMDB counts them.
  final int page;

  const DiscoverMoviesParams({
    this.filters = DiscoverFilters.none,
    this.sort = DiscoverSort.popularity,
    this.page = 1,
  });

  @override
  List<Object?> get props => [filters, sort, page];
}

class DiscoverMoviesUseCase extends UseCase<Either<Failure, PaginatedList<MovieEntity>>, DiscoverMoviesParams> {
  final MovieRepository _movieRepository;

  DiscoverMoviesUseCase(this._movieRepository);

  @override
  Future<Either<Failure, PaginatedList<MovieEntity>>> call({DiscoverMoviesParams? params}) async {
    return await _movieRepository.discoverMovies(
      filters: params!.filters,
      sort: params.sort,
      page: params.page,
    );
  }
}

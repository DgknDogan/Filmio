import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/series_entity.dart';
import '../repositories/series_repository.dart';
import '../repositories/watched_series_repository.dart';

/// The watched list as titles: the stored ids, each looked up in the
/// catalogue — together, since none waits on another — and kept in the order
/// they were marked.
///
/// A title the catalogue cannot answer for is left out rather than sinking the
/// rest. Only when none comes back does the list fail, and then with the most
/// recent title's reason.
class GetWatchedSeriesUseCase extends UseCase<Either<Failure, List<SeriesEntity>>, void> {
  final WatchedSeriesRepository _watchedSeriesRepository;
  final SeriesRepository _seriesRepository;

  GetWatchedSeriesUseCase(this._watchedSeriesRepository, this._seriesRepository);

  @override
  Future<Either<Failure, List<SeriesEntity>>> call({void params}) async {
    final idsResult = await _watchedSeriesRepository.getWatchedSeriesIds();

    return idsResult.fold(
      (failure) async => Left(failure),
      (ids) async {
        if (ids.isEmpty) return const Right([]);

        final results = await Future.wait(ids.map((id) => _seriesRepository.getSeriesDetails(seriesId: id)));

        final titles = <SeriesEntity>[];
        final failures = <Failure>[];
        for (final result in results) {
          result.fold(failures.add, titles.add);
        }

        return titles.isEmpty ? Left(failures.first) : Right(titles);
      },
    );
  }
}

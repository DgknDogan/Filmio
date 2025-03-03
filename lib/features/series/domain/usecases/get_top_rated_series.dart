import '../../../../core/resources/data_state.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/series_entity.dart';
import '../repository/series_repository.dart';

class GetTopRatedSeriesUseCase extends UseCase<DataState<List<SeriesEntity>>, void> {
  final SeriesRepository _seriesRepository;

  GetTopRatedSeriesUseCase(this._seriesRepository);

  @override
  Future<DataState<List<SeriesEntity>>> call({void params}) {
    return _seriesRepository.getTopRatedSeries();
  }
}

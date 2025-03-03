import '../../../../core/resources/data_state.dart';
import '../entities/series_entity.dart';

abstract class SeriesRepository {
  Future<DataState<List<SeriesEntity>>> getPopularSeries();
  Future<DataState<List<SeriesEntity>>> getTopRatedSeries();
}

part of 'series_bloc.dart';

sealed class SeriesState {
  final List<SeriesEntity>? popularSeriesList;
  final List<SeriesEntity>? topSeriesList;
  final SeriesEntity? recommendedSeries;
  final DioException? error;

  const SeriesState({
    this.popularSeriesList,
    this.topSeriesList,
    this.recommendedSeries,
    this.error,
  });
}

final class SeriesLoading extends SeriesState {
  const SeriesLoading();
}

final class SeriesError extends SeriesState {
  const SeriesError(DioException error) : super(error: error);
}

final class SeriesSuccess extends SeriesState {
  const SeriesSuccess(
    List<SeriesEntity>? popularSeriesList,
    List<SeriesEntity>? topSeriesList,
    SeriesEntity? recommendedSeries,
  ) : super(
          popularSeriesList: popularSeriesList,
          recommendedSeries: recommendedSeries,
          topSeriesList: topSeriesList,
        );
}

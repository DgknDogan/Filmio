part of '../cubit/series_home_page_cubit.dart';

class SeriesHomePageState {
  final bool isLoading;
  final List<SeriesModel> popularSeriesList;
  final List<SeriesModel> topSeriesList;
  final SeriesModel? recommendedSeries;

  SeriesHomePageState({
    required this.isLoading,
    required this.popularSeriesList,
    required this.topSeriesList,
    this.recommendedSeries,
  });

  SeriesHomePageState copyWith({
    bool? isLoading,
    List<SeriesModel>? popularSeriesList,
    List<SeriesModel>? topSeriesList,
    SeriesModel? recommendedSeries,
  }) {
    return SeriesHomePageState(
      isLoading: isLoading ?? this.isLoading,
      recommendedSeries: recommendedSeries ?? this.recommendedSeries,
      popularSeriesList: popularSeriesList ?? this.popularSeriesList,
      topSeriesList: topSeriesList ?? this.topSeriesList,
    );
  }
}

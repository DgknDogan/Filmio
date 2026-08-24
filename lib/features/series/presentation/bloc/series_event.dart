part of 'series_bloc.dart';

sealed class SeriesEvent {
  const SeriesEvent();
}

final class GetSeries extends SeriesEvent {}

/// The series at the head of the tab, picked for the signed-in user by
/// Filmio's own service rather than by TMDB.
final class GetRecommendedSeries extends SeriesEvent {}

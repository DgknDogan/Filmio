part of 'series_bloc.dart';

sealed class SeriesEvent {
  const SeriesEvent();
}

final class GetSeries extends SeriesEvent {}

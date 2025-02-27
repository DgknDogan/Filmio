import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../data/series_repository.dart';
import '../models/series_model.dart';

part '../states/series_home_page_state.dart';

class SeriesHomePageCubit extends Cubit<SeriesHomePageState> {
  SeriesHomePageCubit()
      : super(
          SeriesHomePageState(
            isLoading: true,
            popularSeriesList: [],
            topSeriesList: [],
          ),
        ) {
    _init();
  }

  final _seriesRepository = SeriesRepository();

  Future<void> _init() async {
    await getRandomTopRatedSeries();
    await getPopularSeries();
    await getTopRatedSeries();
    Future.delayed(
      1.seconds,
      () {
        emit(state.copyWith(isLoading: false));
      },
    );
  }

  Future<void> getRandomTopRatedSeries() async {
    final topSeriesList = await _seriesRepository.getTopRatedSeries(page: 2);
    final randomSelectedSeries = topSeriesList[Random().nextInt(topSeriesList.length)];
    emit(state.copyWith(recommendedSeries: randomSelectedSeries));
  }

  Future<void> getPopularSeries() async {
    final popularSeriesList = await _seriesRepository.getPopularSeries();
    if (popularSeriesList.isEmpty) {
      emit(state.copyWith(popularSeriesList: popularSeriesList));
      return;
    }
    emit(state.copyWith(popularSeriesList: popularSeriesList));
  }

  Future<void> getTopRatedSeries() async {
    final topSeriesList = await _seriesRepository.getTopRatedSeries(page: 1);
    if (topSeriesList.isEmpty) {
      emit(state.copyWith(topSeriesList: topSeriesList));
      return;
    }
    emit(state.copyWith(topSeriesList: topSeriesList));
  }
}

import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../data/film_repository.dart';
import '../models/film_model.dart';

part '../states/film_home_page_state.dart';

class FilmHomePageCubit extends Cubit<FilmHomePageState> {
  FilmHomePageCubit()
      : super(
          FilmHomePageState(
            popularFilmsList: [],
            topFilmsList: [],
            isLoading: true,
          ),
        ) {
    _init();
  }

  final _filmRepository = FilmRepository();

  Future<void> _init() async {
    await getRandomTopRatedMovie();
    await getPopularMovies();
    await getTopRatedMovies();
    Future.delayed(
      1.seconds,
      () {
        emit(state.copyWith(isLoading: false));
      },
    );
  }

  Future<void> getPopularMovies() async {
    final popularFilmsList = await _filmRepository.getPopularMovies();
    if (popularFilmsList.isEmpty) {
      emit(state.copyWith(popularFilmsList: popularFilmsList));
      return;
    }
    emit(state.copyWith(popularFilmsList: popularFilmsList));
  }

  Future<void> getTopRatedMovies() async {
    final topFilmsList = await _filmRepository.getTopRatedMovies(page: 1);
    if (topFilmsList.isEmpty) {
      emit(state.copyWith(topFilmsList: topFilmsList));
      return;
    }
    emit(state.copyWith(topFilmsList: topFilmsList));
  }

  Future<void> getRandomTopRatedMovie() async {
    final topFilmsList = await _filmRepository.getTopRatedMovies(page: 2);
    final randomSelectedFilm = topFilmsList[Random().nextInt(topFilmsList.length)];
    emit(state.copyWith(recommendedFilm: randomSelectedFilm));
  }
}

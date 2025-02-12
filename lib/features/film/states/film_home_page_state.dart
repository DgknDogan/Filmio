part of '../cubit/film_home_page_cubit.dart';

class FilmHomePageState {
  final List<FilmModel> popularFilmsList;
  final List<FilmModel> topFilmsList;
  final bool isLoading;

  FilmHomePageState({
    required this.popularFilmsList,
    required this.topFilmsList,
    required this.isLoading,
  });

  FilmHomePageState copyWith({
    List<FilmModel>? popularFilmsList,
    List<FilmModel>? topFilmsList,
    bool? isLoading,
  }) {
    return FilmHomePageState(
      popularFilmsList: popularFilmsList ?? this.popularFilmsList,
      isLoading: isLoading ?? this.isLoading,
      topFilmsList: topFilmsList ?? this.topFilmsList,
    );
  }
}

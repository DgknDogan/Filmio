import 'package:bloc/bloc.dart';

part '../states/details_state.dart';

class DetailsCubit extends Cubit<DetailsState> {
  DetailsCubit()
      : super(
          DetailsState(isMovieLiked: false),
        ) {
    // isMovieLiked();
  }

  // final _user = UserRepository();

  // void isMovieLiked() async {
  //   final likedMovieList = await _user.getLikedMoviesList();
  //   if (likedMovieList.contains(film)) {
  //     emit(state.copyWith(isMovieLiked: true));
  //     return;
  //   }
  //   emit(state.copyWith(isMovieLiked: false));
  // }

  // void likeMovie() async {
  //   final likedMovieList = await _user.getLikedMoviesList();
  //   likedMovieList.add(film);
  //   await _user.updateLikedMoviesList(likedFilmList: likedMovieList);
  //   emit(state.copyWith(isMovieLiked: true));
  // }

  // void dislikeMovie() async {
  //   final likedMovieList = await _user.getLikedMoviesList();
  //   likedMovieList.remove(film);
  //   await _user.updateLikedMoviesList(likedFilmList: likedMovieList);
  //   emit(state.copyWith(isMovieLiked: false));
  // }
}

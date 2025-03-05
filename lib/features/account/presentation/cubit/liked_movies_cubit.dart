import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part '../states/liked_movies_state.dart';

class LikedMoviesCubit extends Cubit<LikedMoviesState> {
  LikedMoviesCubit() : super(LikedMoviesInitial());
}

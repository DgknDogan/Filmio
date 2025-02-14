import 'package:bloc/bloc.dart';

part 'details_state.dart';

class DetailsCubit extends Cubit<DetailsState> {
  DetailsCubit() : super(DetailsState(isMovieLiked: false));

  void likeMovie() {
    emit(state.copyWith(isMovieLiked: !state.isMovieLiked));
  }
}

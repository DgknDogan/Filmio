import 'package:bloc/bloc.dart';

part '../../states/series_details_state.dart';

class SeriesDetailsCubit extends Cubit<SeriesDetailsState> {
  SeriesDetailsCubit()
      : super(
          SeriesDetailsState(
            isMovieLiked: false,
            isOpacityAnimating: false,
            isPageShrinked: true,
          ),
        );

  void changePageView() {
    emit(state.copyWith(isPageShrinked: !state.isPageShrinked, isOpacityAnimating: true));
  }

  void finishAnimation() {
    emit(state.copyWith(isOpacityAnimating: false));
  }
}

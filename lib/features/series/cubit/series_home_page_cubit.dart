import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part '../states/series_home_page_state.dart';

class SeriesHomePageCubit extends Cubit<SeriesHomePageState> {
  SeriesHomePageCubit() : super(SeriesHomePageInitial());
}

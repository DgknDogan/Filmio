part of 'title_list_cubit.dart';

sealed class TitleListState<T> extends Equatable {
  const TitleListState();

  @override
  List<Object?> get props => [];
}

final class TitleListLoading<T> extends TitleListState<T> {
  const TitleListLoading();
}

final class TitleListLoaded<T> extends TitleListState<T> {
  final List<T> titles;

  const TitleListLoaded(this.titles);

  @override
  List<Object?> get props => [titles];
}

final class TitleListFailure<T> extends TitleListState<T> {
  final String message;

  const TitleListFailure(this.message);

  @override
  List<Object?> get props => [message];
}

import 'package:equatable/equatable.dart';

/// The foot of a list that loads a page at a time: waiting to be asked, asking,
/// or reporting that the last ask failed.
///
/// Kept apart from the state of the list itself because the two answer
/// different questions — fetching page four is not the same as having nothing
/// to show — and shared because every paged list in the app has the same three
/// answers.
sealed class LoadMoreState extends Equatable {
  const LoadMoreState();

  @override
  List<Object?> get props => [];
}

final class LoadMoreIdle extends LoadMoreState {
  const LoadMoreIdle();
}

final class LoadMoreInProgress extends LoadMoreState {
  const LoadMoreInProgress();
}

final class LoadMoreFailure extends LoadMoreState {
  final String message;

  const LoadMoreFailure(this.message);

  @override
  List<Object?> get props => [message];
}

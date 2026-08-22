part of 'trailer_cubit.dart';

/// Whether there is a trailer to offer, which is a question with three
/// answers rather than a value that might be null: still asking, there is one,
/// there is none — plus the failure that is none of the three.
sealed class TrailerState extends Equatable {
  const TrailerState();

  @override
  List<Object?> get props => [];
}

final class TrailerLoading extends TrailerState {
  const TrailerLoading();
}

/// The title has no video this app can play. Distinct from a failure: nothing
/// went wrong, there is simply nothing to show.
final class TrailerUnavailable extends TrailerState {
  const TrailerUnavailable();
}

final class TrailerReady extends TrailerState {
  final VideoEntity trailer;

  const TrailerReady(this.trailer);

  @override
  List<Object?> get props => [trailer];
}

final class TrailerFailure extends TrailerState {
  final String message;

  const TrailerFailure(this.message);

  @override
  List<Object?> get props => [message];
}

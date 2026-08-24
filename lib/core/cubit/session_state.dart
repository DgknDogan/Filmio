part of 'session_cubit.dart';

/// One fact, so a plain value rather than a set of phases.
final class SessionState extends Equatable {
  final bool isGuest;

  const SessionState({this.isGuest = false});

  @override
  List<Object?> get props => [isGuest];
}

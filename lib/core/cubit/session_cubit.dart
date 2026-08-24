import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../features/auth/domain/usecases/guest_session.dart';

part 'session_state.dart';

/// Whether the app is being used with an account or without one.
///
/// App-level, provided above the router the way `ThemeCubit` is, because the
/// answer changes what four unrelated screens draw — the account tab, the
/// settings screen, and the heart on both details screens — and none of them
/// should have to ask the auth feature for it separately.
class SessionCubit extends Cubit<SessionState> {
  final IsGuestUseCase _isGuestUseCase;
  final ContinueAsGuestUseCase _continueAsGuestUseCase;
  final EndGuestSessionUseCase _endGuestSessionUseCase;

  SessionCubit(
    this._isGuestUseCase,
    this._continueAsGuestUseCase,
    this._endGuestSessionUseCase,
  ) : super(const SessionState()) {
    refresh();
  }

  /// Re-reads the stored flag. Called on the way in, and again after signing
  /// in or out, when the answer has changed underneath.
  Future<void> refresh() async {
    final isGuest = await _isGuestUseCase.call();
    if (!isClosed) emit(SessionState(isGuest: isGuest));
  }

  Future<void> startGuestSession() async {
    await _continueAsGuestUseCase.call();
    if (!isClosed) emit(const SessionState(isGuest: true));
  }

  /// What "create an account" does first: a guest heading for the sign-in
  /// screen stops being a guest before they get there, so cancelling half way
  /// cannot leave them in both states at once.
  Future<void> endGuestSession() async {
    await _endGuestSessionUseCase.call();
    if (!isClosed) emit(const SessionState());
  }
}

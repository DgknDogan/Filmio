import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../auth/domain/usecases/restore_session.dart';

part 'splash_state.dart';

/// Decides where the app goes after the splash animation finishes.
class SplashCubit extends Cubit<SplashState> {
  final RestoreSessionUseCase _restoreSessionUseCase;

  SplashCubit(this._restoreSessionUseCase) : super(const SplashChecking());

  Future<void> resolveDestination() async {
    final hasSession = await _restoreSessionUseCase.call();
    if (isClosed) return;
    emit(hasSession ? const SplashAuthenticated() : const SplashUnauthenticated());
  }
}

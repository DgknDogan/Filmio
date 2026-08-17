part of 'splash_cubit.dart';

sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

/// The animation is still running, or the session check has not finished.
final class SplashChecking extends SplashState {
  const SplashChecking();
}

/// A previous session was restored — go straight to the app.
final class SplashAuthenticated extends SplashState {
  const SplashAuthenticated();
}

/// No session to restore — the user has to sign in.
final class SplashUnauthenticated extends SplashState {
  const SplashUnauthenticated();
}

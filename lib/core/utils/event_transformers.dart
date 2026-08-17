import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

/// Waits for the typing to stop, then keeps only the last request.
///
/// Two things at once, and both are needed:
///
/// `debounceTime` is what stops a request per keystroke — "matrix" is six
/// events and one search. `switchMap` is what handles the ones that do get
/// through: it drops the previous handler when a new event arrives, so a slow
/// early response cannot land on top of a fast later one. Without it a search
/// bloc has to carry a "was this the latest query?" flag and check it by hand
/// after every await.
///
/// This is `bloc_concurrency`'s `restartable()` with a wait in front of it, so
/// that package would be a second way of saying the same thing.
EventTransformer<T> debounceRestartable<T>([
  Duration duration = const Duration(milliseconds: 300),
]) {
  return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
}

import 'package:firebase_auth/firebase_auth.dart';

abstract class FirebaseState<T> {
  final T? data;
  final FirebaseException? error;

  FirebaseState({this.data, this.error});
}

class FirebaseSuccess<T> extends FirebaseState<T> {
  FirebaseSuccess({required T data}) : super(data: data);
}

class FirebaseError<T> extends FirebaseState<T> {
  FirebaseError({required FirebaseException error}) : super(error: error);
}

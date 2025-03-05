import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/resources/firebase_state.dart';

abstract class AuthRepository {
  Future<FirebaseState<UserCredential>> login({required String email, required String password});
  Future<FirebaseState<UserCredential>> register({required String email, required String password});
  Future<void> logout();
}

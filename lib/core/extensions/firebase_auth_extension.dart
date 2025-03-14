import 'package:firebase_auth/firebase_auth.dart';

extension FirebaseExtension on FirebaseAuth {
  String get getUserId => FirebaseAuth.instance.currentUser!.uid;

  User? get getUser => FirebaseAuth.instance.currentUser;

  String get userPhoto => FirebaseAuth.instance.currentUser!.photoURL!;
}

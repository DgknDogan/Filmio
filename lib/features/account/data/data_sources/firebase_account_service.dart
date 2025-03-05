import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAccountService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDocumentSnapshot() async {
    return await _firestore.collection("User").doc(_auth.currentUser!.uid).get();
  }
}

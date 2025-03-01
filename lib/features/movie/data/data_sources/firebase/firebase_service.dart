import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/constants/constants.dart' show userCollection;

class FirebaseService {
  final _firebaseDb = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  FirebaseService() {
    log("Service working");
  }

  String? getUserId() {
    return _auth.currentUser!.uid;
  }

  DocumentReference<Map<String, dynamic>> getUserDocumentRef({required String uid}) {
    return _firebaseDb.collection(userCollection).doc(uid);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../extensions/firebase_auth_extension.dart';

extension FirebaseFirestoreExtension on FirebaseFirestore {
  DocumentReference<Map<String, dynamic>> getUserDocRef() {
    return FirebaseFirestore.instance.collection("User").doc(FirebaseAuth.instance.getUserId);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/constants.dart';

extension FirebaseFirestoreExtension on FirebaseFirestore {
  /// The document holding one user's data. Takes the uid rather than reading
  /// `FirebaseAuth.instance` itself, so callers stay injectable.
  DocumentReference<Map<String, dynamic>> userDoc(String uid) => collection(userCollection).doc(uid);
}

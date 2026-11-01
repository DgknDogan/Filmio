import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';

import '../extensions/firebase_firestore_extension.dart';
import '../resource/failure.dart';
import '../resource/failure_mapper.dart';

/// One list of titles an account keeps, as an array field on its own user
/// document.
///
/// A title in such a list is its TMDB id, and nothing else. That is the whole
/// reason this reads and rewrites the array itself instead of leaving it to
/// `arrayUnion` and `arrayRemove`: those compare whole maps, and the same
/// title does not arrive as the same map twice. A list entry carries bare
/// genre ids where the detail endpoint names them in full, and `popularity`,
/// `vote_average` and `vote_count` all drift between one visit and the next.
/// So the same film added from a row and from its own screen used to land in
/// the list twice, and taking it back out — which asks `arrayRemove` to match
/// a map it no longer has — used to quietly do nothing.
///
/// Every list in the app works this way, which is why this is one class with
/// the differences passed in rather than a file per list: there were two
/// copies of it before the watchlist, and the watchlist would have made four.
/// What differs between them is the field they live in, whether anything
/// mirrors them, and what to do after a change — not how the rewrite works.
class FirestoreTitleList<T> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// The array field on the user document. Also the JSON shape [fromJson] and
  /// [toJson] read and write, so renaming it orphans data already on the
  /// server.
  final String field;

  /// A subcollection mirroring this list, one document per title holding its
  /// id and nothing else — or null when nothing reads such a projection.
  ///
  /// It exists for the recommendation service, which reads the liked titles
  /// with the Admin SDK and wants them one document at a time rather than as
  /// one array it has to parse. A list nothing reads that way does not get a
  /// mirror: an unread projection is a second thing to keep correct.
  final String? mirrorCollection;

  /// The title's TMDB id, which is what identity means in these lists.
  ///
  /// Nullable because the catalogue can hand back a title without one. Such a
  /// title cannot be told apart from any other, so nothing is dropped on its
  /// behalf and it gets no mirror document — better a stray entry than
  /// somebody else's title gone.
  final int? Function(T title) idOf;

  final Map<String, dynamic> Function(T title) toJson;
  final T Function(Map<String, dynamic> json) fromJson;

  /// What this list says when nobody is signed in.
  ///
  /// Per list rather than shared: it is read out to somebody who was trying
  /// to do one specific thing, and "the titles you like" is the wrong sentence
  /// in front of a watchlist.
  final String signedOutMessage;

  /// Run with the signed-in user's id after a change has landed, and not at
  /// all when the write failed.
  final Future<void> Function(String userId)? onChanged;

  FirestoreTitleList({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required this.field,
    required this.idOf,
    required this.toJson,
    required this.fromJson,
    required this.signedOutMessage,
    this.mirrorCollection,
    this.onChanged,
  })  : _firestore = firestore,
        _auth = auth;

  /// The signed-in user's document, or null when nobody is signed in.
  ///
  /// Nullable rather than a bang: a guest reaches these screens with no
  /// Firebase user at all, and a list that cannot be read is a failure to
  /// report, not a crash.
  DocumentReference<Map<String, dynamic>>? get _userDoc {
    final uid = _auth.currentUser?.uid;
    return uid == null ? null : _firestore.userDoc(uid);
  }

  /// The list as titles.
  Future<Either<Failure, List<T>>> read() async {
    final doc = _userDoc;
    if (doc == null) return Left(AuthFailure(signedOutMessage));

    try {
      final userDoc = await doc.get();

      if (!userDoc.exists || userDoc.data() == null) {
        return const Left(ServerFailure('That record no longer exists.'));
      }

      return Right(_entries(userDoc.data()).map(fromJson).toList());
    } on FirebaseException catch (e) {
      return Left(failureFromFirebase(e));
    }
  }

  /// Rewrites the list without [title] in it, adding it back when [include].
  ///
  /// Adding a title already in the list therefore replaces its entry rather
  /// than appending a second one, which also refreshes what the list holds
  /// about it.
  ///
  /// In a transaction because the list is read before it is written: two
  /// screens writing at once would otherwise each store a list that does not
  /// know about the other's.
  Future<Either<Failure, Unit>> write(T title, {required bool include}) async {
    // The user id rather than the document, because [onChanged] is keyed by
    // it too.
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Left(AuthFailure(signedOutMessage));

    final doc = _firestore.userDoc(uid);
    final id = idOf(title);

    try {
      await _firestore.runTransaction<void>((transaction) async {
        final snapshot = await transaction.get(doc);

        final kept = [
          for (final entry in _rawEntries(snapshot.data()))
            if (id == null || entry['id'] != id) entry,
        ];

        transaction.update(doc, {
          field: [...kept, if (include) toJson(title)],
        });

        final mirror = mirrorCollection;
        if (id != null && mirror != null) {
          final mirrorDoc = doc.collection(mirror).doc('$id');
          if (include) {
            transaction.set(mirrorDoc, {'id': id});
          } else {
            transaction.delete(mirrorDoc);
          }
        }
      });

      await onChanged?.call(uid);

      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(failureFromFirebase(e));
    }
  }

  /// The array as it is stored, entry by entry.
  List<Map<String, dynamic>> _rawEntries(Map<String, dynamic>? data) {
    final stored = data?[field];
    if (stored is! List) return [];

    return [for (final entry in stored) Map<String, dynamic>.from(entry as Map)];
  }

  /// The array with any id that appears more than once kept only the first
  /// time.
  ///
  /// Duplicates should not reach this after the rewrite above, but accounts
  /// that collected them under the old behaviour still carry them, and a list
  /// showing the same title twice is the bug the reader actually sees.
  List<Map<String, dynamic>> _entries(Map<String, dynamic>? data) {
    final seen = <Object?>{};

    return [
      for (final entry in _rawEntries(data))
        if (entry['id'] == null || seen.add(entry['id'])) entry,
    ];
  }
}

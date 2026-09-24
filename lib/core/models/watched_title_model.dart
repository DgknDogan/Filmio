import 'package:cloud_firestore/cloud_firestore.dart';

/// One document under a user's `WatchedMovies` or `WatchedSeries`
/// collection: the TMDB id, and when it was marked.
///
/// Shared by both catalogues because the record is the same for either — it
/// holds an id, not the title, so the list is always drawn from TMDB and never
/// goes stale.
class WatchedTitleModel {
  static const idField = 'id';
  static const timestampField = 'timestamp';

  final int id;

  /// Null only for a write the server has not stamped yet.
  final DateTime? timestamp;

  const WatchedTitleModel({required this.id, this.timestamp});

  /// Reads a stored record. The document id stands in when the `id` field is
  /// missing, since the two are written as the same number; a record with
  /// neither is not a title and comes back null.
  static WatchedTitleModel? fromFirestore(String documentId, Map<String, dynamic> data) {
    final id = (data[idField] as num?)?.toInt() ?? int.tryParse(documentId);
    if (id == null) return null;

    final timestamp = data[timestampField];
    return WatchedTitleModel(id: id, timestamp: timestamp is Timestamp ? timestamp.toDate() : null);
  }

  /// What a new record is written as. The time comes from the server, not the
  /// device clock, so the list orders the same on every device.
  Map<String, dynamic> toFirestore() => {
        idField: id,
        timestampField: FieldValue.serverTimestamp(),
      };
}

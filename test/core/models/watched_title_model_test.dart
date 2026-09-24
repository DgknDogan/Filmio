import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmio/core/models/watched_title_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('fromFirestore', () {
    test('reads the id and the stamped time', () {
      final model = WatchedTitleModel.fromFirestore('550', {
        'id': 550,
        'timestamp': Timestamp.fromMillisecondsSinceEpoch(1000),
      })!;

      expect(model.id, 550);
      expect(model.timestamp, DateTime.fromMillisecondsSinceEpoch(1000));
    });

    test('falls back to the document id when the field is missing', () {
      expect(WatchedTitleModel.fromFirestore('550', const {})!.id, 550);
    });

    test('a write the server has not stamped yet has no time', () {
      expect(WatchedTitleModel.fromFirestore('550', const {'id': 550})!.timestamp, isNull);
    });

    test('a record with no usable id is not a title', () {
      expect(WatchedTitleModel.fromFirestore('not-a-number', const {}), isNull);
    });
  });

  test('toFirestore writes the id and asks the server for the time', () {
    final data = const WatchedTitleModel(id: 550).toFirestore();

    expect(data['id'], 550);
    expect(data['timestamp'], FieldValue.serverTimestamp());
  });
}

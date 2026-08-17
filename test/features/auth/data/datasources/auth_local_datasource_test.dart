import 'package:filmio/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<(AuthLocalDataSource, SharedPreferences)> dataSourceWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    final preferences = await SharedPreferences.getInstance();
    return (AuthLocalDataSource(preferences), preferences);
  }

  test('is not remembered until something says otherwise', () async {
    final (dataSource, _) = await dataSourceWith({});

    expect(dataSource.isRemembered, isFalse);
  });

  test('round-trips the remembered flag', () async {
    final (dataSource, _) = await dataSourceWith({});

    await dataSource.setRemembered(true);
    expect(dataSource.isRemembered, isTrue);

    await dataSource.setRemembered(false);
    expect(dataSource.isRemembered, isFalse);
  });

  test('clearRemembered forgets the flag', () async {
    final (dataSource, preferences) = await dataSourceWith({'is_remembered': true});

    await dataSource.clearRemembered();

    expect(dataSource.isRemembered, isFalse);
    expect(preferences.containsKey('is_remembered'), isFalse);
  });

  group('purgeLegacyCredentials', () {
    test('deletes the plaintext e-mail and password earlier builds stored', () async {
      // The security fix this guards: those two keys must not survive an
      // upgrade, and no code path may recreate them.
      final (dataSource, preferences) = await dataSourceWith({
        'email': 'someone@example.com',
        'password': 'hunter2',
        'is_remembered': true,
      });

      await dataSource.purgeLegacyCredentials();

      expect(preferences.containsKey('email'), isFalse);
      expect(preferences.containsKey('password'), isFalse);
    });

    test('leaves the remembered flag alone', () async {
      final (dataSource, _) = await dataSourceWith({'password': 'hunter2', 'is_remembered': true});

      await dataSource.purgeLegacyCredentials();

      expect(dataSource.isRemembered, isTrue);
    });

    test('is a no-op on a clean install', () async {
      final (dataSource, preferences) = await dataSourceWith({});

      await dataSource.purgeLegacyCredentials();

      expect(preferences.getKeys(), isEmpty);
    });
  });
}

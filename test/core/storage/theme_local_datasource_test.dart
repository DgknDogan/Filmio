import 'package:filmio/core/enums/device_theme.dart';
import 'package:filmio/core/storage/theme_local_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ThemeLocalDataSource> dataSourceWith(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  return ThemeLocalDataSource(await SharedPreferences.getInstance());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('readTheme', () {
    test('defaults to system when nothing has been stored', () async {
      final dataSource = await dataSourceWith({});

      expect(dataSource.readTheme(), DeviceTheme.system);
    });

    test('reads back each theme written by this version', () async {
      for (final theme in DeviceTheme.values) {
        final dataSource = await dataSourceWith({});
        await dataSource.writeTheme(theme);

        expect(dataSource.readTheme(), theme, reason: theme.name);
      }
    });

    test('still understands the display labels earlier builds persisted', () async {
      const legacy = {'Light': DeviceTheme.light, 'Dark': DeviceTheme.dark, 'System': DeviceTheme.system};

      for (final entry in legacy.entries) {
        final dataSource = await dataSourceWith({'theme': entry.key});

        expect(dataSource.readTheme(), entry.value, reason: entry.key);
      }
    });

    test('falls back to system instead of throwing on an unrecognised value', () async {
      // The old lookup used firstWhere with no orElse, so a stale or renamed
      // value threw a StateError on launch.
      final dataSource = await dataSourceWith({'theme': 'Açık'});

      expect(dataSource.readTheme(), DeviceTheme.system);
    });
  });

  group('writeTheme', () {
    test('persists the stable name, never the translatable label', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();

      await ThemeLocalDataSource(preferences).writeTheme(DeviceTheme.dark);

      expect(preferences.getString('theme'), 'dark');
    });

    test('reading a legacy label and writing again migrates the stored value', () async {
      SharedPreferences.setMockInitialValues({'theme': 'Dark'});
      final preferences = await SharedPreferences.getInstance();
      final dataSource = ThemeLocalDataSource(preferences);

      await dataSource.writeTheme(dataSource.readTheme());

      expect(preferences.getString('theme'), 'dark');
    });
  });
}

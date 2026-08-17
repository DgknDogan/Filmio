import 'dart:convert';
import 'dart:io';

/// Reads a captured API response from `test/fixtures/`.
String fixture(String name) => File('test/fixtures/$name').readAsStringSync();

/// Same, already decoded.
Map<String, dynamic> fixtureJson(String name) => jsonDecode(fixture(name)) as Map<String, dynamic>;

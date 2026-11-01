/// Which Firebase project a build talks to — and so whose data it can change.
enum AppFlavor {
  dev,
  prod;

  /// The flavor a build is carrying.
  ///
  /// [buildFlavor] is Flutter's own `appFlavor`: the `--flavor` the build was
  /// started with. It is read first because it is the same switch the native
  /// configuration follows — on Android it selects the product flavor, and
  /// with it which `google-services.json` is compiled in. Taking the flavor
  /// from anywhere else in preference to it is how Dart and the native SDK end
  /// up pointed at two different projects.
  ///
  /// [defined] is the `FLAVOR` dart-define, and it exists for iOS: `--flavor`
  /// needs an Xcode scheme of that name there and fails the build without one,
  /// so until those schemes exist this is how an iOS build says what it is.
  ///
  /// Neither one set means [dev]. A build that forgot to say what it is gets
  /// the project where being wrong costs nothing; defaulting the other way
  /// makes a forgotten switch write to the data people are actually using.
  static AppFlavor resolve({String? buildFlavor, String? defined}) {
    final name = buildFlavor == null || buildFlavor.isEmpty ? defined : buildFlavor;

    return values.firstWhere((flavor) => flavor.name == name, orElse: () => dev);
  }
}

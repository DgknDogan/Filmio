# Assets, Network Images, and Localization

Read this when adding an image, icon, or font, displaying a remote image, or adding user-facing text.

## Contents

- [Assets with flutter_gen](#assets-with-flutter_gen)
- [Network images with cached_network_image](#network-images-with-cached_network_image)
- [Localization with ARB files](#localization-with-arb-files)
- [The flutter_gen / l10n conflict](#the-flutter_gen--l10n-conflict)

---

## Assets with flutter_gen

**String-based asset paths are forbidden.** `Image.asset('assets/images/logo.png')` compiles and then fails at runtime if the path is wrong, the file moved, or the entry is missing from `pubspec.yaml`. FlutterGen turns the asset list into Dart code, so the same mistake becomes a compile error and the IDE can autocomplete every asset.

Setup — the generator is a dev dependency; no runtime package is needed because the output lands in `lib/gen/`:

```yaml
dev_dependencies:
  build_runner: ^2.12.0
  flutter_gen_runner: ^5.15.0

flutter_gen:
  output: lib/gen/
  # Enable an integration only once its package is actually a dependency:
  # integrations:
  #   flutter_svg: true
  #   lottie: true

flutter:
  assets:
    - assets/images/
    - assets/icons/
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
```

Adding an asset is a three-step loop: drop the file into `assets/`, make sure its directory is listed under `flutter: assets:`, then regenerate:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Usage — always through `Assets.*`, never a string:

```dart
// Widget directly
Assets.images.logo.image(width: 120, fit: BoxFit.contain)

// ImageProvider, for DecorationImage / CircleAvatar
CircleAvatar(backgroundImage: Assets.images.avatarPlaceholder.provider())

// SVG — only if flutter_svg is a dependency and its integration is enabled
Assets.icons.menu.svg(width: 24, colorFilter: const ColorFilter.mode(...))

// Raw path — only where an API demands a String
Assets.images.logo.path
```

Rules:

- Never write `'assets/...'` in Dart. If a path string appears in a diff, it is a bug.
- Never edit `lib/gen/*.gen.dart`. Fix the asset or `pubspec.yaml` and regenerate.
- Commit the generated files, so CI does not need to run the generator before the project compiles.
- A new asset without a `build_runner` run does not exist as far as the code is concerned — regenerate before writing the widget that uses it.
- Icons that are single-colour shapes belong in `assets/icons/` as SVGs and go through `Assets.icons.*`; do not mix a custom icon font into the same project without asking in chat first.

## Network images with cached_network_image

Every image loaded from a URL goes through `cached_network_image`. `Image.network` is forbidden: it re-downloads on every rebuild, has no disk cache, and gives no clean way to show a placeholder or handle a failure.

The package's own documented usage — a placeholder while loading and an error widget on failure:

```dart
CachedNetworkImage(
  imageUrl: url,
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
)
```

For a determinate spinner, `progressIndicatorBuilder` replaces `placeholder` — the two are mutually exclusive, and the builder receives download progress:

```dart
CachedNetworkImage(
  imageUrl: url,
  progressIndicatorBuilder: (context, url, downloadProgress) =>
      CircularProgressIndicator(value: downloadProgress.progress),
  errorWidget: (context, url, error) => const Icon(Icons.error),
)
```

When an `ImageProvider` is required — a `DecorationImage`, a `CircleAvatar` — use `imageBuilder` to keep the placeholder behaviour, or `CachedNetworkImageProvider` when no placeholder is needed:

```dart
CachedNetworkImage(
  imageUrl: url,
  imageBuilder: (context, imageProvider) => Container(
    decoration: BoxDecoration(
      image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
    ),
  ),
  placeholder: (context, url) => const AppShimmer(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
)
```

**Wrap it once.** Never call `CachedNetworkImage` directly in a feature widget — put a single `AppNetworkImage` in `core/custom/` and use that everywhere, so the placeholder and error appearance are consistent across the app and can be restyled in one place:

```dart
// core/custom/app_network_image.dart
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => const AppShimmer(),
      errorWidget: (context, url, error) =>
          Assets.images.imagePlaceholder.image(width: width, height: height, fit: fit),
    );
  }
}
```

Note how the error fallback comes from `Assets.*` — the two rules compose.

Further points from the package documentation:

- **Always set both a placeholder and an error widget.** Without a placeholder the image pops in with no layout reservation; without an error widget a failed load leaves a broken gap.
- **Give the image a bounded size** (`width`/`height`, or a sized parent). The widget does not assume an infinite size, and an unbounded parent produces layout errors.
- **Cap decode size for thumbnails** with `memCacheWidth`/`memCacheHeight` (memory) or `maxWidthDiskCache`/`maxHeightDiskCache` (disk). A list of 60 avatars decoding at full resolution is a common source of memory pressure.
- **Web caching is limited.** Both the widget and the provider have only minimal web support and do not currently cache there — do not rely on cache behaviour for the web target.
- **A failed load looks like a crash but is not.** The debugger may pause and the console may print the error because the Dart VM does not treat it as caught; crash reporters may even report it. The `errorWidget` still handles it. Do not add try/catch scaffolding around the widget to "fix" this.
- Files are stored through `flutter_cache_manager`. Only configure a custom `cacheManager` when there is a real requirement, such as authenticated image URLs or a bespoke eviction policy.

## Localization with ARB files

All user-facing text comes from `.arb` files, generated by Flutter's own `gen-l10n` tool. No third-party localization package, and no hardcoded strings in widgets.

`pubspec.yaml`:

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: any
```

`l10n.yaml` at the project root:

```yaml
arb-dir: lib/config/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
nullable-getter: false
```

`nullable-getter: false` matters: it makes the generated getter non-nullable, so call sites need no `!`. That is what lets `context.l10n` be clean.

Generate with:

```bash
flutter gen-l10n
```

The ARB template is the source of truth. Give every key a description — translators and future readers have no other context:

```json
{
  "@@locale": "en",
  "staffTitle": "Staff",
  "@staffTitle": {
    "description": "Title of the staff list screen"
  },
  "greeting": "Hello {userName}",
  "@greeting": {
    "description": "Greeting on the home screen",
    "placeholders": {
      "userName": { "type": "String", "example": "Ada" }
    }
  },
  "itemCount": "{count, plural, =0{No items} =1{1 item} other{{count} items}}",
  "@itemCount": {
    "description": "Number of items in the cart",
    "placeholders": {
      "count": { "type": "num", "format": "compact" }
    }
  },
  "lastSeenOn": "Last seen on {date}",
  "@lastSeenOn": {
    "description": "Date a staff member was last active",
    "placeholders": {
      "date": { "type": "DateTime", "format": "yMd" }
    }
  }
}
```

Translation files carry the same keys without the `@` metadata:

```json
{
  "@@locale": "tr",
  "staffTitle": "Personel",
  "greeting": "Merhaba {userName}"
}
```

Use ICU plural and select syntax rather than building sentences in Dart. `'$count ${count == 1 ? 'item' : 'items'}'` is correct in English and wrong in most other languages; plural categories are a property of the language, and only the generator knows them.

Wire the delegates once, in `MaterialApp.router`, using the generated lists:

```dart
MaterialApp.router(
  routerConfig: sl<AppRouter>().config(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
)
```

Call sites always go through the extension in `core/extensions/`:

```dart
// core/extensions/context_extensions.dart
extension L10nExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
```

```dart
Text(context.l10n.staffTitle)
Text(context.l10n.greeting(user.name))
Text(context.l10n.itemCount(cart.length))
```

Rules:

- `context.l10n.propertyName` is the only accepted form. Not `AppLocalizations.of(context)!.x`, not a raw string, not a constant in a Dart file.
- A new string means editing `app_en.arb` first, then every other `.arb`, then regenerating. A key missing from a translation falls back to the template language silently — check the untranslated-messages output rather than assuming.
- Localization must be initialized before use: `AppLocalizations` is only available once the app has started, so never reach for it in `main()` or before the first frame.
- Text that belongs to an error case lives on the `Failure` (see `references/data-layer.md`); localize it by mapping the failure type to an `l10n` key in the widget layer, not by putting translated strings in the data layer.
- Locale switching, if the app needs it, goes through an app-level cubit in `core/cubit/` that holds the locale and rebuilds `MaterialApp` — not through `Localizations.override`, which is for isolated subtrees.
- Do not edit `app_localizations.dart` or any `app_localizations_*.dart`; they are generated.

## The flutter_gen / l10n conflict

FlutterGen and Flutter's older synthetic-package localization output collide — both used the `flutter_gen` package name, and running the two together produces `UnexpectedOutputException` or a `Bad state: No element` failure from `flutter_gen_runner`.

Avoid it with the configuration above, which is exactly what FlutterGen's documentation recommends:

- Do **not** put `generate: true` under `flutter:` in `pubspec.yaml`.
- Run `flutter gen-l10n` explicitly instead of relying on generation during `flutter run`.
- On Flutter versions that still support the flag, set `synthetic-package: false` in `l10n.yaml` so localizations are written next to the ARB files rather than into a synthetic package. Newer Flutter versions have dropped the synthetic package and write to `arb-dir` by default, so the flag may be unnecessary — check whether the current SDK still accepts it before adding it.
- If the project has a custom `build.yaml`, list `pubspec.yaml` as a build source, or FlutterGen fails to see its own configuration:

```yaml
targets:
  $default:
    sources:
      include:
        - pubspec.yaml
```

If code generation misbehaves after touching assets or ARB files, run the full sequence before debugging anything else:

```bash
flutter clean
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
```

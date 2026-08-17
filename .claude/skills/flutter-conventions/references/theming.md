# Theming and Styling

Read this before writing any widget that has a colour, a text style, a corner radius, or a box decoration.

## Contents

- [The rule](#the-rule)
- [What lives where](#what-lives-where)
- [Reading the theme in a widget](#reading-the-theme-in-a-widget)
- [Adding a colour slot](#adding-a-colour-slot)
- [Adding a semantic text style](#adding-a-semantic-text-style)
- [Spacing](#spacing)
- [Decorations and radii](#decorations-and-radii)
- [Styling a component](#styling-a-component)
- [Dark mode](#dark-mode)

---

## The rule

A widget never names a colour, a font size, or a radius. It names a *slot* and the theme decides the value for the brightness currently in effect.

```dart
// Forbidden
Container(color: const Color(0xff616161))
Text('Toplam', style: TextStyle(fontSize: 14, color: Colors.grey))
BorderRadius.circular(13)

// Correct
Container(color: context.palette.textSecondary)
Text('Toplam', style: context.textTheme.labelMedium)
BorderRadius.circular(AppRadius.medium)
```

This is the same principle as `Assets.*` for images and `context.l10n.*` for text: nothing user-facing is addressed by a literal. A hardcoded grey is invisible in review and then unreadable in dark mode.

## What lives where

Everything is under `config/theme/`, and `theme.dart` is the barrel — importing it gives you the palette, shapes, and typography too.

| File | Holds | Rule |
|---|---|---|
| `app_colors.dart` | `AppColors` — brightness-independent constants (the brand orange, categorical chart fills), and `AppPalette` — every colour slot, in a light and a dark set | The **only** file allowed to contain `Color(0x…)` |
| `app_shapes.dart` | `AppSpacing` and `AppInsets` — the spacing scale; `AppRadius` corner constants; `AppDecorations` — the repeated `BoxDecoration`s built from a palette | No `BoxDecoration` that appears twice stays inline |
| `app_typography.dart` | `AppTypography` — the `TextTheme` and the semantic `AppTextStyles`, all built through one private `_font` helper | The **only** file allowed to call `GoogleFonts` or construct a `TextStyle` from scratch |
| `theme.dart` | `lightTheme` / `darkTheme`, both produced by a single `_themeOf(palette)`, plus every component theme | Component styling goes here, never at the call site |

`AppPalette` and `AppTextStyles` are `ThemeExtension`s registered in `ThemeData.extensions`, which is what makes `context.palette` and `context.styles` work.

## Reading the theme in a widget

Through the extensions in `core/extensions/`, never through `Theme.of(context)` spelled out:

```dart
extension ThemeExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  AppPalette get palette => theme.extension<AppPalette>()!;
  AppTextStyles get styles => theme.extension<AppTextStyles>()!;
  TextTheme get textTheme => theme.textTheme;
}
```

Which one to reach for:

- **A colour** → `context.palette.<slot>`
- **Running text, a heading, a label** → `context.textTheme.<role>`
- **Text that carries meaning rather than a size** — a price, a stat value, a validation message → `context.styles.<name>`
- **A radius** → `AppRadius.<size>`
- **A gap or a padding** → `AppSpacing.<size>`, or an `AppInsets.<name>` preset
- **A repeated surface** → `AppDecorations(context.palette).<name>`

Slots are named by purpose, not by appearance. `textSecondary`, not `grey600`; `surfaceMuted`, not `lightGrey`. That is what allows the same name to be near-black in one brightness and near-white in the other.

## Adding a colour slot

A new slot touches five places in `AppPalette`, and missing one fails in a way that is easy to overlook — a forgotten `lerp` entry only shows up as a colour that snaps instead of cross-fading during a theme switch:

1. The `final Color` field, with a doc comment saying what it is *for*
2. The constructor's `required this.x`
3. Both `light` and `dark` const sets
4. `copyWith`
5. `_props` **and** `lerp`

Before adding one, check whether an existing slot means the same thing. Twenty-seven purposeful slots are maintainable; sixty near-duplicates are not.

Values that never change with brightness — a brand colour used as a fixed value, categorical fills that always carry white text — belong in `AppColors`, not in both palette sets.

## Adding a semantic text style

`AppTextStyles` is for text whose *meaning* is fixed, not its size: a price is bold and in the brand colour wherever it appears. If the style is just "a heading" or "body text", it belongs in the `TextTheme` scale instead.

The scale maps to roles, not sizes:

- `headline*` — page and section headings
- `title*` — the heading of a card, sheet, or dialog
- `body*` — running text; a bare `Text` gets `bodyMedium`
- `label*` — buttons, form field labels, chart furniture

Build every new style through `AppTypography._font` so the family stays swappable from one line. Never call `GoogleFonts` anywhere else.

A one-off tweak on an existing style is fine at the call site — `context.textTheme.titleSmall?.copyWith(color: context.palette.primary)` — as long as the colour still comes from the palette. If the same `copyWith` appears three times, it is a semantic style and belongs in `AppTextStyles`.

## Spacing

Every gap and every pad is a multiple of four, taken from the scale. A `12` typed directly into an `EdgeInsets` is indistinguishable from a `13` typed by accident; a name is not.

```dart
/// The spacing scale. Everything is a multiple of four — a value that is not
/// on this scale is a mistake, not a design decision.
abstract final class AppSpacing {
  /// 4 — an icon and its label, two lines of the same block.
  static const double xs = 4;

  /// 8 — items in a dense list, padding inside a chip.
  static const double sm = 8;

  /// 12 — the default. Card padding, the gap between a row's children.
  static const double md = 12;

  /// 16 — page margins, the gap between form fields.
  static const double lg = 16;

  /// 24 — between the sections of a page.
  static const double xl = 24;

  /// 32 — above a page's primary action, below a page heading.
  static const double xxl = 32;
}

/// The paddings that repeat, so they are not respelled at every call site.
abstract final class AppInsets {
  /// The margin around a page's scrolling content.
  static const EdgeInsets page = EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: AppSpacing.md,
  );

  /// Inside a card, panel, or list tile.
  static const EdgeInsets card = EdgeInsets.all(AppSpacing.md);

  /// Inside a bottom sheet, which needs more room at the bottom.
  static const EdgeInsets sheet = EdgeInsets.fromLTRB(
    AppSpacing.lg,
    AppSpacing.lg,
    AppSpacing.lg,
    AppSpacing.xl,
  );
}
```

Usage:

```dart
Padding(padding: AppInsets.page, child: ...)
Container(padding: AppInsets.card, decoration: AppDecorations(context.palette).card)
const SizedBox(height: AppSpacing.lg)
const EdgeInsets.symmetric(horizontal: AppSpacing.md)
```

Rules:

- Never type a bare number into an `EdgeInsets`, a `SizedBox`, a `Gap`, or a `spacing:` argument. If the value you want is not on the scale, pick the nearer step — do not add a `14`.
- Two paddings that keep appearing together earn an `AppInsets` preset, the same way a repeated `BoxDecoration` earns an `AppDecorations` getter.
- New steps are added to the scale only when a real layout needs one, and only as a multiple of four.
- **This does not apply to sizes that are not spacing**: a border width, a divider thickness, a shadow blur or offset, an icon or avatar dimension, a fixed component height. Those stay literal, and inside `config/theme/` a component theme may use whatever a Material widget actually needs.

## Decorations and radii

`AppRadius` has four sizes and nothing in between; a radius that is not one of them is a bug, not a design decision.

`AppDecorations` takes the palette, so a card is white on light and near-black on dark without the caller choosing:

```dart
Container(
  decoration: AppDecorations(context.palette).card,
  child: ...,
)
```

State-dependent decorations are methods rather than getters — `selectable(isSelected: true)`. Follow that shape rather than branching on state at the call site.

## Styling a component

If a Material widget can be themed centrally, theme it centrally. `theme.dart` already configures buttons, inputs, dialogs, sheets, tabs, checkboxes, switches, dividers, list tiles, expansion tiles, popup menus, progress indicators, text selection, icons, and the Cupertino overrides.

So: a plain `ElevatedButton` already has the right shape, colour, padding, and label style. Do not pass `style:` at the call site to reproduce what the theme gives you. A `style:` override is for a genuine one-off; if the same override appears twice, it belongs in `theme.dart`.

When adding a new component theme, add it to `_themeOf` — never build a second `ThemeData`. Both brightnesses come from that one function precisely so a component cannot drift between them.

## Dark mode

The dark set is not the light set inverted, and it is not something to add later. Both sets are written together, because the decisions are coupled: lightening the brand orange for a dark field forces the text on top of it to flip to near-black.

Practical consequences:

- Every new slot needs a value in **both** sets, chosen for that background — not a mechanical inversion.
- Anything sitting on a saturated fill uses `onFill` / `onPrimary`, not `Colors.white`.
- Shadows are heavier in dark mode; they come from `palette.shadow`, never from a literal.
- Check a new screen in both brightnesses before considering it done.

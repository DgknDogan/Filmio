import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A four-based spacing scale. Widgets name a step; they never write a number.
///
/// `flutter_screenutil` is not part of the project's declared stack, so it is
/// confined to this file and [AppRadius]: every value is scaled with `.r`
/// (the smaller of the width and height factors) so a step is the same size
/// horizontally and vertically. Dropping screenutil later means changing these
/// getters and nothing else.
abstract final class AppSpacing {
  /// 4
  static double get xs => 4.r;

  /// 8
  static double get sm => 8.r;

  /// 12
  static double get md => 12.r;

  /// 16
  static double get lg => 16.r;

  /// 20
  static double get xl => 20.r;

  /// 24
  static double get xxl => 24.r;

  /// 32
  static double get xxxl => 32.r;

  /// 40
  static double get huge => 40.r;
}

/// The corner radii the app uses. A radius outside this set is a bug.
///
/// The three small steps are the design system's `--radius-sm/md/lg`; the two
/// large ones are the app's own, for shapes the system does not describe.
abstract final class AppRadius {
  /// 4 — a checkbox, a chip.
  static double get xs => 4.r;

  /// 8 — the default: fields, buttons, cards.
  static double get sm => 8.r;

  /// 14 — sheets and dialogs.
  static double get md => 14.r;

  static double get lg => 20.r;

  /// The sweep at the top of the details sheet.
  static double get sheet => 22.r;
  static double get pill => 45.r;

  static BorderRadius get xsAll => BorderRadius.circular(xs);
  static BorderRadius get smAll => BorderRadius.circular(sm);
  static BorderRadius get mdAll => BorderRadius.circular(md);
  static BorderRadius get lgAll => BorderRadius.circular(lg);
  static BorderRadius get pillAll => BorderRadius.circular(pill);
}

/// Padding presets, so a screen never assembles `EdgeInsets` from numbers.
abstract final class AppInsets {
  /// The standard left/right page gutter.
  static EdgeInsets get pageHorizontal => EdgeInsets.symmetric(horizontal: AppSpacing.xl);

  /// Gutter on all four sides.
  static EdgeInsets get page => EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xl);

  static EdgeInsets get right => EdgeInsets.only(right: AppSpacing.xl);
  static EdgeInsets get left => EdgeInsets.only(left: AppSpacing.xl);

  /// Spacing around a card in a list.
  static EdgeInsets get listCard => EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm);

  /// The foot of a tab page. The bar floats over the content, so the last
  /// row needs its height back as padding or it cannot be scrolled clear.
  static EdgeInsets get tabBody => EdgeInsets.only(bottom: AppSpacing.huge + AppSpacing.xxxl + AppSpacing.xxl);

  /// The gutter of an auth screen — wider than [pageHorizontal], which is
  /// what gives the form its column.
  static EdgeInsets get authHorizontal => EdgeInsets.symmetric(horizontal: AppSpacing.xxl);

  /// The headline and fields of an auth screen: that gutter, room under the
  /// banner, and a floor under the last field. The actions below it carry
  /// their own padding, since they sit at the bottom of the viewport rather
  /// than at the end of the form.
  static EdgeInsets get authBody => EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xxl,
        AppSpacing.xxl,
        AppSpacing.xl,
      );
}

/// A gap between widgets. Reads better than a bare `SizedBox` and cannot be
/// given an unscaled number.
class AppGap extends StatelessWidget {
  final double? _height;
  final double? _width;

  const AppGap.vertical(double size, {super.key})
      : _height = size,
        _width = null;
  const AppGap.horizontal(double size, {super.key})
      : _width = size,
        _height = null;

  @override
  Widget build(BuildContext context) => SizedBox(height: _height, width: _width);
}

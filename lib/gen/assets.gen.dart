// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsFemaleGen {
  const $AssetsFemaleGen();

  /// File path: assets/female/female1.png
  AssetGenImage get female1 => const AssetGenImage('assets/female/female1.png');

  /// File path: assets/female/female2.png
  AssetGenImage get female2 => const AssetGenImage('assets/female/female2.png');

  /// File path: assets/female/female3.png
  AssetGenImage get female3 => const AssetGenImage('assets/female/female3.png');

  /// File path: assets/female/female4.png
  AssetGenImage get female4 => const AssetGenImage('assets/female/female4.png');

  /// File path: assets/female/female5.png
  AssetGenImage get female5 => const AssetGenImage('assets/female/female5.png');

  /// File path: assets/female/female6.png
  AssetGenImage get female6 => const AssetGenImage('assets/female/female6.png');

  /// List of all assets
  List<AssetGenImage> get values =>
      [female1, female2, female3, female4, female5, female6];
}

class $AssetsMaleGen {
  const $AssetsMaleGen();

  /// File path: assets/male/male1.png
  AssetGenImage get male1 => const AssetGenImage('assets/male/male1.png');

  /// File path: assets/male/male2.png
  AssetGenImage get male2 => const AssetGenImage('assets/male/male2.png');

  /// File path: assets/male/male3.png
  AssetGenImage get male3 => const AssetGenImage('assets/male/male3.png');

  /// File path: assets/male/male4.png
  AssetGenImage get male4 => const AssetGenImage('assets/male/male4.png');

  /// File path: assets/male/male5.png
  AssetGenImage get male5 => const AssetGenImage('assets/male/male5.png');

  /// File path: assets/male/male6.png
  AssetGenImage get male6 => const AssetGenImage('assets/male/male6.png');

  /// List of all assets
  List<AssetGenImage> get values => [male1, male2, male3, male4, male5, male6];
}

abstract final class Assets {
  static const $AssetsFemaleGen female = $AssetsFemaleGen();
  static const AssetGenImage logo = AssetGenImage('assets/logo.png');
  static const $AssetsMaleGen male = $AssetsMaleGen();

  /// List of all assets
  static List<AssetGenImage> get values => [logo];
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}

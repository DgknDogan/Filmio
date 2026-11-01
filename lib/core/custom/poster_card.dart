import 'package:flutter/material.dart';

import '../../config/theme/app_decorations.dart';
import '../../config/theme/app_spacing.dart';
import '../extensions/context_extension.dart';
import 'app_network_image.dart';

/// A poster, at the one aspect ratio and the one treatment the app uses.
///
/// Artwork and nothing else: whatever a screen has to say about the title —
/// its name, its year, its rating — is said beside the poster rather than
/// printed over it. [title] is still required because a picture with no text
/// on it has nothing for a screen reader to announce, so it becomes the
/// poster's label.
class PosterCard extends StatelessWidget {
  final String imageUrl;

  /// Not drawn. What the poster is announced as.
  final String title;

  /// Set when the poster flies into a details screen.
  final Object? heroTag;
  final VoidCallback? onTap;

  /// What the picture is decoded to. The default suits a card at the size a
  /// row or a grid draws one; a preview a few millimetres across passes
  /// something smaller rather than decoding a full poster to throw most of it
  /// away.
  final int memCacheHeight;

  const PosterCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.heroTag,
    this.onTap,
    this.memCacheHeight = 600,
  });

  @override
  Widget build(BuildContext context) {
    final poster = DecoratedBox(
      decoration: AppDecorations(context.palette).poster,
      child: ClipRRect(
        borderRadius: AppRadius.mdAll,
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: AppNetworkImage(url: imageUrl, fit: BoxFit.cover, memCacheHeight: memCacheHeight),
        ),
      ),
    );

    // The default flight shuttle draws the destination for the whole flight,
    // which is exactly right here: both ends of the flight are the same
    // picture in the same card, at two sizes.
    final withHero = heroTag == null ? poster : Hero(tag: heroTag!, child: poster);

    return Semantics(
      image: true,
      label: title,
      button: onTap != null,
      child: onTap == null ? withHero : GestureDetector(onTap: onTap, child: withHero),
    );
  }
}

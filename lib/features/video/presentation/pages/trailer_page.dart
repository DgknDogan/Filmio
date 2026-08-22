import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pod_player/pod_player.dart';

import '../../../../config/theme/app_spacing.dart';
import '../../../../core/custom/circle_icon_button.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../domain/entities/video_entity.dart';

/// The trailer, full screen.
///
/// The player is kept off the details sheet on purpose: it is a heavy widget
/// with its own controller and full-screen handling, and the sheet is already
/// one long scroll with artwork animating behind it.
@RoutePage()
class TrailerPage extends StatefulWidget {
  final VideoEntity trailer;

  const TrailerPage({super.key, required this.trailer});

  @override
  State<TrailerPage> createState() => _TrailerPageState();
}

class _TrailerPageState extends State<TrailerPage> {
  /// The player is a resource rather than screen state — nothing outside this
  /// page acts on it — so it lives here and not in a cubit, which could not
  /// hold it without holding a Flutter object.
  PodPlayerController? _controller;

  late Future<PodPlayerController?> _player;

  @override
  void initState() {
    super.initState();
    _player = _open();
  }

  /// Null means the video is on a host this app has no player for, which is a
  /// message rather than an error. Anything that goes wrong opening a host it
  /// does support throws, and the builder reports it.
  Future<PodPlayerController?> _open() async {
    final source = _sourceFor(widget.trailer);
    if (source == null) return null;

    final controller = PodPlayerController(
      playVideoFrom: source,
      // The size TMDB lists is the resolution the trailer exists in; asking
      // for the same ladder means the player opens at the quality the choice
      // was made on, and steps down only if that is not there.
      podPlayerConfig: const PodPlayerConfig(videoQualityPriority: [1080, 720, 360]),
    );
    _controller = controller;
    await controller.initialise();

    return controller;
  }

  /// Which player the host needs. TMDB serves both, and they are not
  /// interchangeable: YouTube is resolved from a video id, Vimeo from a
  /// numeric one against a different API.
  static PlayVideoFrom? _sourceFor(VideoEntity trailer) {
    final key = trailer.key;
    if (key == null || key.isEmpty) return null;

    return switch (trailer.site) {
      VideoSite.youtube => PlayVideoFrom.youtube(key),
      VideoSite.vimeo => PlayVideoFrom.vimeo(key),
      VideoSite.unknown => null,
    };
  }

  void _retry() => setState(() => _player = _open());

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.videoStage,
      body: Stack(
        children: [
          Center(
            child: FutureBuilder<PodPlayerController?>(
              future: _player,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return _PlayerMessage(message: context.l10n.trailerLoadFailed, onRetry: _retry);
                }

                final controller = snapshot.data;
                if (controller == null) {
                  return _PlayerMessage(message: context.l10n.trailerUnsupported);
                }

                return PodVideoPlayer(
                  controller: controller,
                  backgroundColor: context.palette.videoStage,
                  videoTitle: Text(
                    widget.trailer.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.styles.onImage,
                  ),
                  onVideoError: () => _PlayerMessage(message: context.l10n.trailerLoadFailed, onRetry: _retry),
                );
              },
            ),
          ),
          // Above the player, so the way out stays reachable while the video
          // is still resolving.
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: CircleIconButton(
                icon: Icons.close_rounded,
                label: context.l10n.backAction,
                onPressed: () => context.router.maybePop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// What the stage shows instead of a picture: why there is none, and a way to
/// ask again where asking again could help.
class _PlayerMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _PlayerMessage({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppInsets.page,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.videocam_off_outlined, color: context.palette.onImageMuted, size: AppSpacing.huge),
          AppGap.vertical(AppSpacing.md),
          Text(message, textAlign: TextAlign.center, style: context.styles.onImage),
          if (onRetry != null) ...[
            AppGap.vertical(AppSpacing.sm),
            TextButton(onPressed: onRetry, child: Text(context.l10n.tryAgain)),
          ],
        ],
      ),
    );
  }
}

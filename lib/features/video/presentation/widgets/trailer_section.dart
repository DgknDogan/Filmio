import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/theme/app_spacing.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/custom/app_network_image.dart';
import '../../../../core/custom/section_header.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../domain/entities/video_entity.dart';
import '../cubit/trailer_cubit.dart';

/// The way into a title's trailer, on a film's and a series' details screen
/// alike: a still with a play button over it, which hands the video to
/// YouTube.
///
/// The app deliberately embeds no player. Playing a YouTube video anywhere but
/// YouTube's own player means extracting its stream URLs, which is outside
/// YouTube's terms of use and therefore outside App Review guidelines 5.2.2
/// and 5.2.3 — a rejection with no licence to answer it with. Handing the
/// video over costs a trip out of the app and buys a trailer that keeps
/// working, counts as a view, and carries the uploader's own restrictions.
///
/// It reads the [TrailerCubit] the page provides, so the two screens differ
/// only in which title they stand it up for.
class TrailerSection extends StatelessWidget {
  /// What the card falls back to when the host gives no thumbnail of its own —
  /// the title's own artwork, which the page already has.
  final String fallbackImageUrl;

  const TrailerSection({super.key, required this.fallbackImageUrl});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.palette.sheet,
      child: Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, 0),
        child: BlocBuilder<TrailerCubit, TrailerState>(
          builder: (context, state) {
            return switch (state) {
              TrailerLoading() => SizedBox(height: 96.h, child: const Center(child: CircularProgressIndicator())),
              // A title with no trailer says nothing about it: an empty block
              // under the synopsis would read as something failing.
              TrailerUnavailable() => const SizedBox.shrink(),
              TrailerFailure(:final message) => _SectionFailure(message: message),
              TrailerReady(:final trailer) => _TrailerCard(trailer: trailer, fallbackImageUrl: fallbackImageUrl),
            };
          },
        ),
      ),
    );
  }
}

class _TrailerCard extends StatelessWidget {
  final VideoEntity trailer;
  final String fallbackImageUrl;

  const _TrailerCard({required this.trailer, required this.fallbackImageUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: context.l10n.trailerTitle),
        AppGap.vertical(AppSpacing.md),
        GestureDetector(
          onTap: () => _open(context),
          child: Semantics(
            button: true,
            label: context.l10n.trailerPlay,
            child: ClipRRect(
              borderRadius: AppRadius.smAll,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppNetworkImage(url: _thumbnailUrl, fit: BoxFit.cover),
                    ColoredBox(color: context.palette.overlayScrim),
                    Center(
                      child: Icon(
                        Icons.play_circle_fill_rounded,
                        size: AppSpacing.huge + AppSpacing.md,
                        color: context.palette.onImage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (trailer.name case final name? when name.isNotEmpty) ...[
          AppGap.vertical(AppSpacing.sm),
          Text(name, style: context.styles.meta, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ],
    );
  }

  /// Hands the trailer to whatever the device opens YouTube links with: the
  /// YouTube app if it is installed, the browser otherwise.
  ///
  /// `externalApplication` rather than an in-app web view, so the YouTube app
  /// gets the link when there is one. Nothing on this screen changes as a
  /// result, so there is no state to move into the cubit — only the one case
  /// where the device has nothing to open the link with, which is worth
  /// saying rather than swallowing.
  Future<void> _open(BuildContext context) async {
    // A card only exists for a playable video, so the key is there — but the
    // query parameter is typed loosely enough that a null would reach YouTube
    // as the string "null", and that is not worth risking on an invariant
    // held two classes away.
    final key = trailer.key;
    if (key == null || key.isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);
    final message = context.l10n.trailerOpenFailed;
    final url = Uri.parse(youtubeWatchUrl).replace(queryParameters: {'v': key});

    final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (opened) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// YouTube publishes a still for every video at a fixed address, so the card
  /// shows the trailer itself rather than the title's artwork. The fallback is
  /// still there for a video whose still 404s.
  String get _thumbnailUrl {
    if (trailer.key?.isNotEmpty ?? false) {
      return '$youtubeThumbnailBaseUrl/${trailer.key}/hqdefault.jpg';
    }

    return fallbackImageUrl;
  }
}

/// The trailer could not be looked up. Worth saying rather than hiding: unlike
/// a title with no trailer, asking again may work.
class _SectionFailure extends StatelessWidget {
  final String message;

  const _SectionFailure({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: context.l10n.trailerTitle),
        AppGap.vertical(AppSpacing.sm),
        Text(message, style: context.styles.meta),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => context.read<TrailerCubit>().loadTrailer(),
            child: Text(context.l10n.tryAgain),
          ),
        ),
      ],
    );
  }
}

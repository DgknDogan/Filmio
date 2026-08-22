import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/routes/app_router.gr.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/custom/app_network_image.dart';
import '../../../../core/custom/section_header.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../domain/entities/video_entity.dart';
import '../cubit/trailer_cubit.dart';

/// The way into a title's trailer, on a film's and a series' details screen
/// alike: a still with a play button over it, which opens the player.
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
          onTap: () => context.router.push(TrailerRoute(trailer: trailer)),
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
                    ColoredBox(color: context.palette.overlayScrim.withValues(alpha: 0.35)),
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

  /// YouTube publishes a still for every video at a fixed address, so the card
  /// can show the trailer itself. Vimeo does not without a second API call, so
  /// those fall back to the title's artwork.
  String get _thumbnailUrl {
    if (trailer.site == VideoSite.youtube && (trailer.key?.isNotEmpty ?? false)) {
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

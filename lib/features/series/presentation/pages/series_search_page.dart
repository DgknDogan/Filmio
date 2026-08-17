import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/app_router.gr.dart';
import '../../../../core/custom/app_error_view.dart';
import '../../../../core/custom/poster_card.dart';
import '../../../../core/custom/search_results_grid.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/extensions/string_extension.dart';
import '../../../../core/utils/hero_tags.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/series_entity.dart';
import '../bloc/series_search_bloc.dart';

@RoutePage()
class SeriesSearchPage extends StatefulWidget {
  final String heroTag;
  final String hintText;

  const SeriesSearchPage({super.key, required this.heroTag, required this.hintText});

  @override
  State<SeriesSearchPage> createState() => _SeriesSearchPageState();
}

class _SeriesSearchPageState extends State<SeriesSearchPage> {
  late final FocusNode _focus;
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    _focus = FocusNode();
    Future.delayed(250.milliseconds, _focus.requestFocus);
    super.initState();
  }

  @override
  void dispose() {
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SeriesSearchBloc(getIt()),
      child: _SearchView(controller: _controller, focus: _focus, heroTag: widget.heroTag, hintText: widget.hintText),
    );
  }
}

class _SearchView extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focus;
  final String heroTag;
  final String hintText;

  const _SearchView({required this.controller, required this.focus, required this.heroTag, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<SeriesSearchBloc, SeriesSearchState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchBarRow(
                  heroTag: heroTag,
                  hintText: hintText,
                  controller: controller,
                  focus: focus,
                  // Every keystroke reports itself; the bloc's transformer is
                  // what decides which ones reach the API.
                  onChanged: (query) => context.read<SeriesSearchBloc>().add(SeriesSearchQueryChanged(query)),
                ),
                if (state case SeriesSearchLoaded(:final series))
                  SearchResultsSummary(count: series.length, scope: context.l10n.seriesTitle),
                Expanded(
                  child: switch (state) {
                    SeriesSearchInitial() => const SizedBox.shrink(),
                    SeriesSearchLoading() => const Center(child: CircularProgressIndicator()),
                    SeriesSearchFailure(:final message) => AppErrorView(
                        message: message,
                        onRetry: () => context.read<SeriesSearchBloc>().add(SeriesSearchRetried(controller.text)),
                      ),
                    SeriesSearchLoaded(:final series) when series.isEmpty => AppErrorView(
                        message: context.l10n.searchNoResults,
                      ),
                    SeriesSearchLoaded(:final series) => SearchResultsGrid(
                        children: [
                          // A query can answer with two series of the same
                          // name — a reboot, a local remake — so the grid
                          // position is what tells the two posters apart.
                          for (final (index, entry) in series.indexed)
                            _Result(
                              series: entry,
                              tag: posterHeroTag('series-search', index: index, id: entry.id),
                            ),
                        ],
                      ),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Result extends StatelessWidget {
  final SeriesEntity series;
  final String tag;

  const _Result({required this.series, required this.tag});

  @override
  Widget build(BuildContext context) {
    final meta = [series.firstAirDate?.year, series.voteAverage?.toStringAsFixed(1)].nonNulls.join(' · ');

    return PosterCard(
      imageUrl: series.posterPath?.coverImage ?? '',
      title: series.name ?? '',
      meta: meta,
      heroTag: tag,
      onTap: () => context.router.push(SeriesDetailsRoute(series: series, heroTag: tag)),
    );
  }
}

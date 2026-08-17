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
import '../../domain/entities/movie.dart';
import '../bloc/search_bloc.dart';

@RoutePage()
class MovieSearchPage extends StatefulWidget {
  final String heroTag;
  final String hintText;

  const MovieSearchPage({super.key, required this.heroTag, required this.hintText});

  @override
  State<MovieSearchPage> createState() => _MovieSearchPageState();
}

class _MovieSearchPageState extends State<MovieSearchPage> {
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
      create: (context) => SearchBloc(getIt()),
      // The view is a separate widget so everything inside it reads the bloc
      // from a context *below* the provider. Reading it from this build method
      // throws ProviderNotFoundException.
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
        child: BlocBuilder<SearchBloc, SearchState>(
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
                  onChanged: (query) => context.read<SearchBloc>().add(SearchQueryChanged(query)),
                ),
                if (state case SearchLoaded(:final movies))
                  SearchResultsSummary(count: movies.length, scope: context.l10n.moviesTitle),
                Expanded(
                  child: switch (state) {
                    SearchInitial() => const SizedBox.shrink(),
                    SearchLoading() => const Center(child: CircularProgressIndicator()),
                    SearchFailure(:final message) => AppErrorView(
                        message: message,
                        onRetry: () => context.read<SearchBloc>().add(SearchRetried(controller.text)),
                      ),
                    SearchLoaded(:final movies) when movies.isEmpty => AppErrorView(
                        message: context.l10n.searchNoResults,
                      ),
                    SearchLoaded(:final movies) => SearchResultsGrid(
                        children: [
                          // A query can answer with two films of the same name
                          // — a remake, a re-release — so the grid position is
                          // what tells the two posters apart.
                          for (final (index, movie) in movies.indexed)
                            _Result(
                              movie: movie,
                              tag: posterHeroTag('movie-search', index: index, id: movie.id),
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
  final MovieEntity movie;
  final String tag;

  const _Result({required this.movie, required this.tag});

  @override
  Widget build(BuildContext context) {
    final meta = [movie.releaseDate?.year, movie.voteAverage?.toStringAsFixed(1)].nonNulls.join(' · ');

    return PosterCard(
      imageUrl: movie.posterPath?.coverImage ?? '',
      title: movie.title ?? '',
      meta: meta,
      heroTag: tag,
      onTap: () => context.router.push(MovieDetailsRoute(movie: movie, heroTag: tag)),
    );
  }
}

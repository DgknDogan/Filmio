import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/routes/app_router.gr.dart';
import '../../../../core/extensions/brightness_extension.dart';
import '../../../../core/extensions/string_extension.dart';
import '../../../../core/utils/custom/custom_searchbar.dart';
import '../../../../core/utils/custom/custom_sliver_app_bar.dart';
import '../../../../core/utils/custom/hero_image.dart';
import '../../../../core/utils/custom/recommended_container.dart';
import '../../domain/entities/movie.dart';
import '../bloc/movie_bloc.dart';

@RoutePage()
class MoviePage extends StatelessWidget {
  const MoviePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<MovieBloc>(),
      child: Scaffold(
        body: BlocBuilder<MovieBloc, MovieState>(
          builder: (context, state) {
            if (state is MovieSuccess) {
              return CustomScrollView(
                slivers: [
                  CustomSliverAppBar(
                    title: Text("Movies"),
                    actions: [
                      Container(
                        margin: EdgeInsets.only(right: 20.w),
                        child: GestureDetector(
                          onTap: () => context.router.push(MovieSearchRoute(heroTag: "movie_searchbar", hintText: "Search a movie")),
                          child: Hero(
                            tag: "movie_searchbar",
                            createRectTween: (begin, end) => RectTween(begin: begin, end: end),
                            flightShuttleBuilder: (flightContext, animation, direction, fromContext, toContext) {
                              if (direction == HeroFlightDirection.push) {
                                return Material(color: Colors.transparent, child: fromContext.widget);
                              } else {
                                return Material(color: Colors.transparent, child: toContext.widget);
                              }
                            },
                            child: GestureDetector(
                              child: CustomSearchbar(
                                height: 40.h,
                                width: 200.w,
                                isEnabled: false,
                                hintText: "Search a movie",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        RecommendedContainer(
                          imageUrl: state.recommendedMovie?.posterPath!.coverImage ?? "",
                          tag: "movie_poster",
                          onTap: () => context.router.push(
                            MovieDetailsRoute(movie: state.recommendedMovie!, heroTag: "movie_poster"),
                          ),
                        ),
                        _ScrollableFilmList(
                          title: "Popular Movies",
                          movieList: state.popularFilmsList!,
                          storageKey: PageStorageKey("popular_movies"),
                        ),
                        SizedBox(height: 20.h),
                        _ScrollableFilmList(
                          title: "Top Movies",
                          movieList: state.topFilmsList!,
                          storageKey: PageStorageKey("top_movies"),
                        ),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ],
              );
            } else if (state is MovieLoading) {
              return Center(
                child: CircularProgressIndicator(color: Theme.of(context).isLight ? Colors.black : Colors.white),
              );
            } else {
              return Center(
                child: Text(state.error!.message!),
              );
            }
          },
        ),
      ),
    );
  }
}

class _ScrollableFilmList extends StatelessWidget {
  final String title;
  final List<MovieEntity> movieList;
  final PageStorageKey<String> storageKey;

  const _ScrollableFilmList({
    required this.title,
    required this.movieList,
    required this.storageKey,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieBloc, MovieState>(
      builder: (context, state) {
        return Container(
          margin: EdgeInsets.only(left: 20.w),
          child: Column(
            spacing: 10.h,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 20.w),
                    child: Text(
                      "See more",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 200.h,
                child: ListView.builder(
                  key: storageKey,
                  itemCount: movieList.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return _MovieCard(movie: movieList[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MovieCard extends StatelessWidget {
  final MovieEntity movie;

  const _MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieBloc, MovieState>(
      builder: (context, state) {
        state as MovieSuccess;
        return Container(
          height: 200.h,
          margin: EdgeInsets.only(right: 20.r),
          child: GestureDetector(
            onTap: () => context.router.push(MovieDetailsRoute(movie: movie, heroTag: movie.title!)),
            child: HeroImage(
              tag: movie.title!,
              imageUrl: movie.posterPath!.coverImage,
            ),
          ),
        );
      },
    );
  }
}

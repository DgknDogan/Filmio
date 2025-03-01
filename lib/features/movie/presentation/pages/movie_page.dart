import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmio/config/routes/app_router.gr.dart';
import 'package:filmio/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../injection_container.dart';
import '../../../landing/widgets/recommended_container.dart';
import '../../domain/entities/movie.dart';
import '../bloc/movie_bloc.dart';

@RoutePage()
class MoviePage extends StatelessWidget {
  const MoviePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MovieBloc(getIt(), getIt())..add(GetMovies()),
      child: Scaffold(
        body: BlocBuilder<MovieBloc, MovieState>(
          builder: (context, state) {
            if (state is MovieSuccess) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    RecommendedContainer(
                      isLoading: false,
                      imageUrl: state.recommendedMovie?.posterPath!.coverImage ?? "",
                      tag: "movie_poster",
                      onTap: () => context.router.push(
                        MovieDetailsRoute(movie: state.recommendedMovie!, heroTag: "movie_poster"),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    _ScrollableFilmList(
                      title: "Popular Movies",
                      movieList: state.popularFilmsList!,
                    ),
                    SizedBox(height: 20.h),
                    _ScrollableFilmList(
                      title: "Top Movies",
                      movieList: state.topFilmsList!,
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(color: Colors.white),
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

  const _ScrollableFilmList({
    required this.title,
    required this.movieList,
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...movieList.map(
                      (movie) {
                        return _MovieCard(movie: movie);
                      },
                    )
                  ],
                ),
              )
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
    return Container(
      height: 200.h,
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.only(right: 20.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: GestureDetector(
        onTap: () => context.router.push(MovieDetailsRoute(movie: movie, heroTag: movie.title!)),
        child: Hero(
          tag: movie.title!,
          child: CachedNetworkImage(
            imageUrl: movie.posterPath!.coverImage,
            placeholder: (context, url) => Container(
              decoration: BoxDecoration(color: Colors.transparent),
            ),
            errorWidget: (context, url, error) => SizedBox(),
            memCacheHeight: 1000,
          ),
        ),
      ),
    );
  }
}

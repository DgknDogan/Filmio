import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmio/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../routes/app_router.gr.dart';
import '../../widgets/recommended_container.dart';
import '../cubit/film_home_page_cubit.dart';
import '../models/film_model.dart';

@RoutePage()
class FilmHomePage extends StatelessWidget {
  const FilmHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<FilmHomePageCubit, FilmHomePageState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              children: [
                RecommendedContainer(
                  isLoading: state.isLoading,
                  imageUrl: state.recommendedFilm?.posterPath!.coverImage ?? "",
                  tag: "movie_poster",
                  onTap: () => context.router.push(FilmDetailsRoute(film: state.recommendedFilm!, heroTag: "movie_poster")),
                ),
                SizedBox(height: 20.h),
                _ScrollableFilmList(
                  title: "Popular Movies",
                  filmList: state.popularFilmsList,
                ),
                SizedBox(height: 20.h),
                _ScrollableFilmList(
                  title: "Top Movies",
                  filmList: state.topFilmsList,
                ),
                SizedBox(height: 40.h),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ScrollableFilmList extends StatelessWidget {
  final String title;
  final List<FilmModel> filmList;

  const _ScrollableFilmList({
    required this.title,
    required this.filmList,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilmHomePageCubit, FilmHomePageState>(
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
              if (!state.isLoading)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...filmList.map(
                        (film) {
                          return _FilmCard(film: film);
                        },
                      )
                    ],
                  ),
                )
              else
                SizedBox(
                  height: 200.h,
                  child: ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade400,
                        highlightColor: Colors.grey.shade300,
                        child: Container(
                          width: 133.w,
                          color: Colors.black,
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => SizedBox(width: 10.w),
                    itemCount: 3,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _FilmCard extends StatelessWidget {
  final FilmModel film;

  const _FilmCard({required this.film});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.h,
      // width: 133.w,
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.only(right: 20.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: GestureDetector(
        onTap: () => context.router.push(FilmDetailsRoute(film: film, heroTag: film.title!)),
        child: Hero(
          tag: film.title!,
          child: CachedNetworkImage(
            imageUrl: film.posterPath!.coverImage,
            placeholder: (context, url) => Container(
              decoration: BoxDecoration(color: Colors.transparent),
            ),
            errorWidget: (context, url, error) => SizedBox(),
            memCacheHeight: 300,
          ),
        ),
      ),
    );
  }
}

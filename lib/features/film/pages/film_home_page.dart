import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmio/routes/app_router.gr.dart';
import 'package:filmio/utils/extentions.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/film_home_page_cubit.dart';
import '../models/film_model.dart';

@RoutePage()
class FilmHomePage extends StatelessWidget {
  const FilmHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // final auth = FirebaseAuth.instance;

    return Scaffold(
      body: BlocProvider(
        create: (context) => FilmHomePageCubit(),
        child: BlocBuilder<FilmHomePageCubit, FilmHomePageState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: !state.isLoading
                  ? Column(
                      children: [
                        _RecommendedSection(),
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
                    )
                  : SizedBox(),
            );
          },
        ),
      ),
    );
  }
}

class _RecommendedSection extends StatelessWidget {
  const _RecommendedSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilmHomePageCubit, FilmHomePageState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.only(top: 40.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xff283618),
                Color(0xffFEFAE0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          height: 350.h,
          width: double.infinity,
          child: Column(
            spacing: 25.h,
            children: [
              SizedBox(
                height: 250.h,
                child: GestureDetector(
                  onTap: () => context.router.push(FilmDetailsRoute(film: state.recommendedFilm!, heroTag: "movie_poster")),
                  child: Hero(
                    tag: "movie_poster",
                    child: CachedNetworkImage(
                      imageUrl: state.recommendedFilm!.posterPath!.coverImage,
                      memCacheHeight: 300,
                    ),
                  ),
                ),
              ),
              Text(
                "Recommended for you",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
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
    return Container(
      margin: EdgeInsets.only(left: 20.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              Container(
                margin: EdgeInsets.only(right: 20.w),
                child: Text("See more"),
              ),
            ],
          ),
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
          ),
        ],
      ),
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

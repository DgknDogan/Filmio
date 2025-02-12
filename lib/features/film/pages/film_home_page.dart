import 'package:auto_route/annotations.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
            return SafeArea(
              child: state.isLoading
                  ? Column(
                      children: [
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
                      ],
                    )
                  : Center(
                      child: CircularProgressIndicator(
                        color: Color(0xff283618),
                      ),
                    ),
            );
          },
        ),
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
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.only(right: 20.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          CachedNetworkImage(
            imageUrl: film.posterPath!.coverImage,
            placeholder: (context, url) => Container(
              height: 200,
              width: 133,
              decoration: BoxDecoration(color: Colors.transparent),
            ),
            errorWidget: (context, url, error) => SizedBox(),
            memCacheHeight: 200,
            memCacheWidth: 133,
          ),
        ],
      ),
    );
  }
}

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/series_home_page_cubit.dart';

@RoutePage()
class SeriesHomePage extends StatelessWidget {
  const SeriesHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _RecommendedSection(),
        ],
      ),
    );
  }
}

class _RecommendedSection extends StatelessWidget {
  const _RecommendedSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SeriesHomePageCubit, SeriesHomePageState>(
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
                // child: GestureDetector(
                //   // onTap: () => context.router.push(FilmDetailsRoute(film: state.recommendedFilm!, heroTag: "movie_poster")),
                //   child: Hero(
                //     tag: "movie_poster",
                //     child: CachedNetworkImage(
                //       imageUrl: state.recommendedFilm!.posterPath!.coverImage,
                //       memCacheHeight: 300,
                //     ),
                //   ),
                // ),
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

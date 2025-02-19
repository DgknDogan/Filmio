import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmio/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/details_cubit.dart';
import '../models/film_model.dart';

@RoutePage()
class FilmDetailsPage extends StatelessWidget {
  final FilmModel film;
  final String heroTag;

  const FilmDetailsPage({
    super.key,
    required this.film,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DetailsCubit(film: film),
      child: BlocBuilder<DetailsCubit, DetailsState>(
        builder: (context, state) {
          return Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  scrolledUnderElevation: 0,
                  leading: IconButton(
                    onPressed: () => context.router.maybePop(),
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white70,
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () => !state.isMovieLiked ? context.read<DetailsCubit>().likeMovie() : context.read<DetailsCubit>().dislikeMovie(),
                      icon: Icon(
                        Icons.star_outlined,
                        color: state.isMovieLiked ? Colors.green.shade500 : Colors.white70,
                      ),
                    ),
                  ],
                  backgroundColor: Color(0xff283618),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    spacing: 20.h,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xff283618),
                              Color(0xff606c38),
                              Color(0xffFEFAE0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Hero(
                          tag: heroTag,
                          child: CachedNetworkImage(
                            imageUrl: film.posterPath!.coverImage,
                            height: 300.h,
                            memCacheHeight: 1000,
                          ),
                        ),
                      ),
                      _FilmDescription(film: film),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FilmDescription extends StatelessWidget {
  const _FilmDescription({
    required this.film,
  });

  final FilmModel film;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30.w),
      child: Column(
        spacing: 20.h,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text(
              film.title!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                film.releaseDate!.formattedTime,
                style: TextStyle(fontSize: 16.sp),
              ),
              Row(
                spacing: 5.w,
                children: [
                  Icon(Icons.thumb_up_alt),
                  Text(
                    film.voteAverage!.roundNumber,
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ],
              )
            ],
          ),
          Text(
            film.overview!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.sp),
          ),
          SizedBox()
        ],
      ),
    );
  }
}

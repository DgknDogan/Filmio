import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmio/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/series_entity.dart';

@RoutePage()
class SeriesDeatailsPage extends StatelessWidget {
  final SeriesEntity series;
  final String heroTag;
  const SeriesDeatailsPage({super.key, required this.series, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Color(0xff080808),
            scrolledUnderElevation: 0,
            leading: IconButton(
              onPressed: () => context.router.maybePop(),
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white70,
              ),
            ),
            actions: [
              GestureDetector(
                // onTap: () => !state.isMovieLiked
                //     ? context.read<DetailsCubit>().likeMovie(movie: movie)
                //     : context.read<DetailsCubit>().dislikeMovie(movie: movie),
                child: Container(
                  margin: EdgeInsets.only(right: 15.w),
                  child: Icon(
                    Icons.star_outlined,
                    // color: state.isMovieLiked ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            ],
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
                        Color(0xff080808),
                        Color(0xff3a3a3a),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Hero(
                    tag: heroTag,
                    child: CachedNetworkImage(
                      imageUrl: series.posterPath!.coverImage,
                      height: 300.h,
                      memCacheHeight: 1000,
                    ),
                  ),
                ),
                // _FilmDescription(movie: movie),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmio/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/movie.dart';
import '../cubit/details_cubit.dart';

@RoutePage()
class MovieDetailsPage extends StatelessWidget {
  final MovieEntity movie;
  final String heroTag;

  const MovieDetailsPage({
    super.key,
    required this.movie,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => DetailsCubit(),
        child: BlocBuilder<DetailsCubit, DetailsState>(
          builder: (context, state) {
            return CustomScrollView(
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
                    GestureDetector(
                      // onTap: () => !state.isMovieLiked ? context.read<DetailsCubit>().likeMovie() : context.read<DetailsCubit>().dislikeMovie(),
                      child: Container(
                        margin: EdgeInsets.only(right: 15.w),
                        child: Icon(
                          Icons.star_outlined,
                          color: state.isMovieLiked ? Colors.white : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                  backgroundColor: Color(0xff1c1c1c),
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
                              Color(0xff1c1c1c),
                              Color(0xff3a3a3a),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Hero(
                          tag: heroTag,
                          child: CachedNetworkImage(
                            imageUrl: movie.posterPath!.coverImage,
                            height: 300.h,
                            memCacheHeight: 1000,
                          ),
                        ),
                      ),
                      _FilmDescription(movie: movie),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FilmDescription extends StatelessWidget {
  const _FilmDescription({
    required this.movie,
  });

  final MovieEntity movie;

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
              movie.title!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                movie.releaseDate!.formattedTime,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                movie.voteAverage!.roundNumber.rateNumber,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          Text(
            movie.overview!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}

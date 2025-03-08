import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmio/core/extensions/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/enums/movie_type.dart';
import '../../../../injection_container.dart';
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
    return Stack(
      children: [
        _Backgorund(movie: movie),
        ClipRRect(
          clipBehavior: Clip.hardEdge,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Scaffold(
              extendBodyBehindAppBar: true,
              extendBody: true,
              backgroundColor: Colors.transparent,
              body: BlocProvider(
                create: (context) => DetailsCubit(getIt(), getIt(), movie, getIt()),
                child: _ScrollBody(movie: movie, heroTag: heroTag),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Backgorund extends StatelessWidget {
  const _Backgorund({
    required this.movie,
  });

  final MovieEntity movie;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: CachedNetworkImage(
        imageUrl: movie.posterPath!.coverImage,
        fit: BoxFit.fitHeight,
        memCacheHeight: 1000,
      ),
    );
  }
}

class _ScrollBody extends StatelessWidget {
  const _ScrollBody({
    required this.movie,
    required this.heroTag,
  });

  final MovieEntity movie;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: () => context.router.maybePop(),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          actions: [
            BlocBuilder<DetailsCubit, DetailsState>(
              builder: (context, state) {
                return GestureDetector(
                  onTap: () => !state.isMovieLiked
                      ? context.read<DetailsCubit>().likeMovie(movie: movie)
                      : context.read<DetailsCubit>().dislikeMovie(movie: movie),
                  child: Container(
                    margin: EdgeInsets.only(right: 15.w),
                    child: Icon(
                      Icons.star_outlined,
                      color: state.isMovieLiked ? Colors.amberAccent : Colors.white,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: BlocBuilder<DetailsCubit, DetailsState>(
            builder: (context, state) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  _InformationContainer(movie: movie),
                  _Image(heroTag: heroTag, movie: movie),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Image extends StatelessWidget {
  const _Image({
    required this.heroTag,
    required this.movie,
  });

  final String heroTag;
  final MovieEntity movie;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailsCubit, DetailsState>(
      builder: (context, state) {
        return AnimatedOpacity(
          duration: 500.ms,
          curve: Curves.easeInOut,
          opacity: !state.isOpacityAnimating ? 1 : 0,
          child: !state.isPageShrinking
              ? Container(
                  margin: state.isPageShrinked ? EdgeInsets.only(bottom: 250.h) : EdgeInsets.only(bottom: 420.h, right: 120.w),
                  clipBehavior: Clip.hardEdge,
                  height: state.isPageShrinked ? 300.h : 200.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.r),
                    boxShadow: state.isPageShrinked
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 10.r,
                              offset: Offset(-5.w, 10.h),
                            )
                          ],
                  ),
                  child: Hero(
                    tag: heroTag,
                    child: CachedNetworkImage(
                      imageUrl: movie.posterPath!.coverImage,
                      memCacheHeight: 1000,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              : SizedBox(),
        );
      },
    );
  }
}

class _InformationContainer extends StatelessWidget {
  const _InformationContainer({
    required this.movie,
  });

  final MovieEntity movie;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailsCubit, DetailsState>(
      builder: (context, state) {
        return AnimatedContainer(
          duration: 500.ms,
          curve: Curves.easeInOut,
          margin: state.isPageShrinked ? EdgeInsets.only(top: 150.h, right: 20.w, left: 20.w) : EdgeInsets.only(top: 150.h),
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          onEnd: () {
            context.read<DetailsCubit>().finishShrinking();
          },
          width: double.infinity,
          height: state.isPageShrinked ? 400.h : 600.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(state.isPageShrinked ? 15.r : 0.r),
              bottomRight: Radius.circular(state.isPageShrinked ? 15.r : 0.r),
              topLeft: Radius.circular(state.isPageShrinked ? 15.r : 60.r),
              topRight: Radius.circular(state.isPageShrinked ? 15.r : 60.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 20.r,
                offset: Offset(0, 20.h),
                spreadRadius: 6.r,
              ),
            ],
          ),
          child: AnimatedOpacity(
            duration: 500.ms,
            curve: Curves.easeInOut,
            opacity: !state.isOpacityAnimating ? 1 : 0,
            onEnd: () {
              Future.delayed(
                100.ms,
                () {
                  if (context.mounted) {
                    context.read<DetailsCubit>().finishAnimation();
                  }
                },
              );
            },
            child: !state.isPageShrinking
                ? Container(
                    margin: state.isPageShrinked ? EdgeInsets.only(top: 120.h) : EdgeInsets.only(top: 10.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!state.isPageShrinked) _ExpandedTypeCards(movie: movie) else SizedBox(),
                        Container(height: state.isPageShrinked ? 40.h : 0),
                        Center(
                          child: Text(
                            movie.title!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        if (state.isPageShrinked) _ShrinkedTypeCards(movie: movie) else SizedBox(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Director",
                              style: TextStyle(color: Colors.black),
                            ),
                            Text(
                              "Writers",
                              style: TextStyle(color: Colors.black),
                            ),
                            Text(
                              "Stars",
                              style: TextStyle(color: Colors.black),
                            ),
                            !state.isPageShrinked
                                ? Text(
                                    movie.overview!,
                                    style: TextStyle(color: Colors.black),
                                  )
                                : SizedBox()
                          ],
                        ),
                        Text(
                          "Release Date ${movie.releaseDate!.formattedTime}",
                          style: TextStyle(color: Colors.black),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () => context.read<DetailsCubit>().changePageView(),
                          child: Align(
                            child: Icon(state.isPageShrinked ? Icons.keyboard_arrow_down_outlined : Icons.keyboard_arrow_up_outlined, size: 30.r),
                          ),
                        ),
                        SizedBox(height: 10.h)
                      ],
                    ),
                  )
                : SizedBox(),
          ),
        );
      },
    );
  }
}

class _ShrinkedTypeCards extends StatelessWidget {
  const _ShrinkedTypeCards({required this.movie});

  final MovieEntity movie;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        runSpacing: 10,
        spacing: 10,
        children: [
          ...movie.genreIds!.map(
            (id) => Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade500,
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Text(
                MovieType.getEnumById(id: id),
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandedTypeCards extends StatelessWidget {
  const _ExpandedTypeCards({
    required this.movie,
  });

  final MovieEntity movie;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 130.h,
          margin: EdgeInsets.only(left: 180.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              ...movie.genreIds!.map(
                (id) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade500,
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Text(
                    MovieType.getEnumById(id: id),
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

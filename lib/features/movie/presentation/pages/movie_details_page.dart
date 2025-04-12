import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/routes/app_router.gr.dart';
import '../../../../core/enums/movie_type.dart';
import '../../../../core/extensions/double_extension.dart';
import '../../../../core/extensions/string_extension.dart';
import '../../../../core/utils/custom/hero_image.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/movie.dart';
import '../cubit/movie_details_cubit.dart';

@RoutePage()
class MovieDetailsPage extends StatefulWidget {
  final MovieEntity movie;
  final String heroTag;

  const MovieDetailsPage({
    super.key,
    required this.movie,
    required this.heroTag,
  });

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  @override
  void initState() {
    final tween = Tween<double>(begin: 15, end: 5);
    _controller = AnimationController(vsync: this, duration: 500.ms, reverseDuration: 500.ms);
    _animation = tween.animate(_controller);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MovieDetailsCubit(getIt(), getIt(), widget.movie, getIt(), getIt()),
      child: Stack(
        children: [
          _Background(movie: widget.movie),
          AnimatedBuilder(
            animation: _animation,
            builder: (BuildContext context, Widget? child) {
              return ClipRRect(
                clipBehavior: Clip.hardEdge,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: _animation.value.w, sigmaY: _animation.value.h),
                  child: Scaffold(
                    extendBodyBehindAppBar: true,
                    extendBody: true,
                    backgroundColor: Colors.transparent,
                    body: _ScrollBody(
                      movie: widget.movie,
                      heroTag: widget.heroTag,
                      controller: _controller,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Background extends StatelessWidget {
  const _Background({
    required this.movie,
  });

  final MovieEntity movie;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          Colors.grey.withValues(alpha: 0.8),
          BlendMode.saturation,
        ),
        child: CachedNetworkImage(
          imageUrl: movie.posterPath!.coverImage,
          fit: BoxFit.fitHeight,
          memCacheHeight: 500,
        ),
      ),
    );
  }
}

class _ScrollBody extends StatelessWidget {
  const _ScrollBody({
    required this.movie,
    required this.heroTag,
    required this.controller,
  });

  final MovieEntity movie;
  final String heroTag;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: () => context.router.maybePop(),
            icon: Icon(Icons.arrow_back, color: Colors.white),
          ),
          actions: [
            BlocBuilder<MovieDetailsCubit, MovieDetailsState>(
              builder: (context, state) {
                return GestureDetector(
                  onTap: () => !state.isMovieLiked
                      ? context.read<MovieDetailsCubit>().likeMovie(movie: movie)
                      : context.read<MovieDetailsCubit>().dislikeMovie(movie: movie),
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
          child: Stack(
            alignment: Alignment.center,
            children: [
              _InformationContainer(
                movie: movie,
                controller: controller,
                heroTag: heroTag,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InformationContainer extends StatelessWidget {
  const _InformationContainer({
    required this.movie,
    required this.controller,
    required this.heroTag,
  });

  final MovieEntity movie;
  final AnimationController controller;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieDetailsCubit, MovieDetailsState>(
      builder: (context, state) {
        return AnimatedContainer(
          duration: 500.ms,
          curve: Curves.easeInOut,
          margin: state.isPageShrinked ? EdgeInsets.only(right: 20.w, left: 20.w) : EdgeInsets.only(top: 150.h),
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          width: double.infinity,
          height: state.isPageShrinked ? 400.h : 800.h,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(state.isPageShrinked ? 15.r : 0.r),
              bottomRight: Radius.circular(state.isPageShrinked ? 15.r : 0.r),
              topLeft: Radius.circular(state.isPageShrinked ? 15.r : 60.r),
              topRight: Radius.circular(state.isPageShrinked ? 15.r : 60.r),
            ),
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
                    context.read<MovieDetailsCubit>().finishAnimation();
                  }
                },
              );
            },
            child: state.isPageShrinked
                ? _ShrinkedView(
                    movie: movie,
                    heroTag: heroTag,
                    controller: controller,
                  )
                : _ExpandedView(
                    movie: movie,
                    heroTag: heroTag,
                    controller: controller,
                  ),
          ),
        );
      },
    );
  }
}

class _ShrinkedView extends StatelessWidget {
  final MovieEntity movie;
  final String heroTag;
  final AnimationController controller;
  const _ShrinkedView({required this.movie, required this.heroTag, required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieDetailsCubit, MovieDetailsState>(
      builder: (context, state) {
        if (!state.isOpacityAnimating) {
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: -50.h,
                child: _Image(
                  heroTag: heroTag,
                  movie: movie,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 270.h),
                child: Column(
                  // spacing: 15.h,
                  children: [
                    Text(
                      movie.title!,
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5.h),
                    _ShrinkedTypeCards(movie: movie),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        context.read<MovieDetailsCubit>().changePageView();
                        controller.forward();
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10.h),
                        child: Align(
                          child: Icon(Icons.keyboard_arrow_down_outlined, size: 30.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        } else {
          return SizedBox();
        }
      },
    );
  }
}

class _ExpandedView extends StatelessWidget {
  final MovieEntity movie;
  final String heroTag;
  final AnimationController controller;

  const _ExpandedView({required this.movie, required this.heroTag, required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieDetailsCubit, MovieDetailsState>(
      builder: (context, state) {
        if (!state.isOpacityAnimating) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -80.h,
                left: 30.w,
                child: _Image(heroTag: heroTag, movie: movie),
              ),
              _ExpandedTypeCards(movie: movie),
              Container(
                margin: EdgeInsets.only(top: 140.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            movie.title!,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        Row(
                          spacing: 5.w,
                          children: [
                            Icon(Icons.star, color: Colors.amber),
                            Text(movie.voteAverage!.roundNumber.rateNumber, style: Theme.of(context).textTheme.titleSmall)
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text(movie.overview!),
                    SizedBox(height: 20.h),
                    Text("Similar movies", style: Theme.of(context).textTheme.headlineMedium),
                    SizedBox(height: 10.h),
                    BlocBuilder<MovieDetailsCubit, MovieDetailsState>(
                      builder: (context, state) {
                        return SizedBox(
                          height: 150.h,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            separatorBuilder: (context, index) => SizedBox(width: 15.w),
                            itemCount: state.similarsList.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () => context.router
                                    .push(MovieDetailsRoute(movie: state.similarsList[index], heroTag: state.similarsList[index].title!)),
                                child: HeroImage(
                                  imageUrl: state.similarsList[index].posterPath!.coverImage,
                                  tag: state.similarsList[index].title!,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20.h),
                    // Text("User comments", style: Theme.of(context).textTheme.titleLarge),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        context.read<MovieDetailsCubit>().changePageView();
                        controller.reverse();
                      },
                      child: Align(
                        child: Icon(Icons.keyboard_arrow_up_outlined, size: 30.r),
                      ),
                    ),
                    SizedBox(height: 20.h)
                  ],
                ),
              ),
            ],
          );
        } else {
          return SizedBox();
        }
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
    movie.genreIds!.sort((a, b) => MovieType.getEnumById(id: a).length.compareTo(MovieType.getEnumById(id: b).length));
    return Column(
      children: [
        Container(
          height: 130.h,
          margin: EdgeInsets.only(left: 190.w, top: 10.h),
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

class _Image extends StatelessWidget {
  const _Image({
    required this.heroTag,
    required this.movie,
  });

  final String heroTag;
  final MovieEntity movie;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieDetailsCubit, MovieDetailsState>(
      builder: (context, state) {
        return AnimatedOpacity(
          duration: 500.ms,
          curve: Curves.easeInOut,
          opacity: !state.isOpacityAnimating ? 1 : 0,
          child: Container(
            margin: state.isPageShrinked ? EdgeInsets.only(bottom: 250.h) : EdgeInsets.only(bottom: 420.h, right: 120.w),
            clipBehavior: Clip.hardEdge,
            height: state.isPageShrinked ? 300.h : 200.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: HeroImage(
              tag: heroTag,
              imageUrl: movie.posterPath!.coverImage,
            ),
          ),
        );
      },
    );
  }
}

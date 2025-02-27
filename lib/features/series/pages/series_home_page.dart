import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmio/config/routes/app_router.gr.dart';
import 'package:filmio/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../landing/widgets/recommended_container.dart';
import '../cubit/series_home_page_cubit.dart';
import '../models/series_model.dart';

@RoutePage()
class SeriesHomePage extends StatelessWidget {
  const SeriesHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => SeriesHomePageCubit(),
        child: BlocBuilder<SeriesHomePageCubit, SeriesHomePageState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  RecommendedContainer(
                    imageUrl: state.recommendedSeries?.posterPath!.coverImage ?? "",
                    tag: "series_poster",
                    isLoading: state.isLoading,
                    onTap: () => context.router.push(
                      SeriesDeatailsRoute(),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _ScrollableFilmList(title: "Popular Series", seriesList: state.popularSeriesList),
                  SizedBox(height: 20.h),
                  _ScrollableFilmList(title: "Top Series", seriesList: state.topSeriesList),
                  SizedBox(height: 40.h),
                ],
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
  final List<SeriesModel> seriesList;

  const _ScrollableFilmList({
    required this.title,
    required this.seriesList,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SeriesHomePageCubit, SeriesHomePageState>(
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
                      ...seriesList.map(
                        (series) {
                          return _SeriesCard(series: series);
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

class _SeriesCard extends StatelessWidget {
  final SeriesModel series;

  const _SeriesCard({required this.series});

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
        onTap: () => context.router.push(SeriesDeatailsRoute()),
        child: Hero(
          tag: series.name!,
          child: CachedNetworkImage(
            imageUrl: series.posterPath!.coverImage,
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

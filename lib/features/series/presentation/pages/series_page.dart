import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmio/config/routes/app_router.gr.dart';
import 'package:filmio/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../injection_container.dart';
import '../../../../core/utils/custom/recommended_container.dart';
import '../../domain/entities/series_entity.dart';
import '../bloc/series_bloc.dart';

@RoutePage()
class SeriesHomePage extends StatelessWidget {
  const SeriesHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => SeriesBloc(getIt(), getIt())..add(GetSeries()),
        child: BlocBuilder<SeriesBloc, SeriesState>(
          builder: (context, state) {
            if (state is SeriesSuccess) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    RecommendedContainer(
                      imageUrl: state.recommendedSeries?.posterPath!.coverImage ?? "",
                      tag: "series_poster",
                      onTap: () => context.router.push(
                        SeriesDeatailsRoute(series: state.recommendedSeries!, heroTag: "series_poster"),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    _ScrollableFilmList(
                      title: "Popular Series",
                      seriesList: state.popularSeriesList!,
                      storageKey: PageStorageKey("popular_series"),
                    ),
                    SizedBox(height: 20.h),
                    _ScrollableFilmList(
                      title: "Top Series",
                      seriesList: state.topSeriesList!,
                      storageKey: PageStorageKey("top_series"),
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class _ScrollableFilmList extends StatelessWidget {
  final String title;
  final List<SeriesEntity> seriesList;
  final PageStorageKey<String> storageKey;

  const _ScrollableFilmList({
    required this.title,
    required this.seriesList,
    required this.storageKey,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SeriesBloc, SeriesState>(
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
              SizedBox(
                height: 200.h,
                child: ListView.builder(
                  key: storageKey,
                  itemCount: seriesList.length,
                  scrollDirection: Axis.horizontal,
                  cacheExtent: 500,
                  itemBuilder: (context, index) {
                    return _SeriesCard(series: seriesList[index]);
                  },
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
  final SeriesEntity series;

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
        onTap: () => context.router.push(SeriesDeatailsRoute(series: series, heroTag: series.name!)),
        child: Hero(
          tag: series.name!,
          child: CachedNetworkImage(
            imageUrl: series.posterPath!.coverImage,
            placeholder: (context, url) => Container(
              decoration: BoxDecoration(color: Colors.transparent),
            ),
            errorWidget: (context, url, error) => SizedBox(),
            memCacheHeight: 1000,
          ),
        ),
      ),
    );
  }
}

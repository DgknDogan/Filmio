import 'package:auto_route/auto_route.dart';
import 'package:filmio/config/routes/app_router.gr.dart';
import 'package:filmio/core/extensions/double_extension.dart';
import 'package:filmio/core/extensions/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/enums/movie_type.dart';
import '../../../../core/utils/custom/hero_image.dart';
import '../cubit/liked_movies_cubit.dart';

@RoutePage()
class LikedMoviesPage extends StatelessWidget {
  const LikedMoviesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => LikedMoviesCubit(),
        child: BlocBuilder<LikedMoviesCubit, LikedMoviesState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  title: Text("Liked Movies"),
                  centerTitle: true,
                  titleTextStyle: Theme.of(context).textTheme.titleLarge,
                  leading: GestureDetector(
                    onTap: () => context.router.maybePop(),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                ),
                SliverList.separated(
                  itemCount: state.list.length,
                  separatorBuilder: (context, index) => SizedBox(height: 0.h),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => context.router.push(MovieDetailsRoute(movie: state.list[index], heroTag: state.list[index].id.toString())),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
                        height: 150.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          color: Colors.white,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 10.w,
                          children: [
                            SizedBox(
                              height: 140.h,
                              width: 100.w,
                              child: HeroImage(
                                tag: state.list[index].id.toString(),
                                imageUrl: state.list[index].posterPath!.coverImage,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          ...state.list[index].genreIds!.map(
                                            (genreId) {
                                              return Text(
                                                MovieType.getEnumById(id: genreId),
                                                style: TextStyle(color: Colors.black),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      Text(
                                        state.list[index].voteAverage!.roundNumber,
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "data",
                                    style: TextStyle(color: Colors.black),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

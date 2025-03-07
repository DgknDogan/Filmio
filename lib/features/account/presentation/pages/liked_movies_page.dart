import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmio/core/extensions/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                      width: double.infinity,
                      height: 150.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: Colors.white,
                      ),
                      child: Row(
                        spacing: 10.w,
                        children: [
                          Container(
                            clipBehavior: Clip.hardEdge,
                            margin: EdgeInsets.only(left: 5.w),
                            height: 140.h,
                            width: 100.w,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(7.5.r)),
                            child: CachedNetworkImage(
                              imageUrl: state.list[index].posterPath!.coverImage,
                              memCacheHeight: 1000,
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                state.list[index].title!,
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          )
                        ],
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

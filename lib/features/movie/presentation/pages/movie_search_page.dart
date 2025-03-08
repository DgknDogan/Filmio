import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmio/core/extensions/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/utils/custom/custom_searchbar.dart';
import '../../../../injection_container.dart';
import '../cubit/search_cubit.dart';

@RoutePage()
class MovieSearchPage extends StatefulWidget {
  final String heroTag;
  final String hintText;

  const MovieSearchPage({super.key, required this.heroTag, required this.hintText});

  @override
  State<MovieSearchPage> createState() => _MovieSearchPageState();
}

class _MovieSearchPageState extends State<MovieSearchPage> {
  final _focus = FocusNode();
  @override
  void initState() {
    Future.delayed(
      250.milliseconds,
      () {
        _focus.requestFocus();
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchCubit(getIt()),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actionsPadding: EdgeInsets.only(right: 20.w),
          actions: [
            Row(
              children: [
                Hero(
                  tag: widget.heroTag,
                  child: BlocBuilder<SearchCubit, SearchState>(
                    builder: (context, state) {
                      return CustomSearchbar(
                        onChanged: (query) {
                          context.read<SearchCubit>().searchMovies(query: query);
                        },
                        width: 260.w,
                        isEnabled: true,
                        focusNode: _focus,
                        hintText: widget.hintText,
                      );
                    },
                  ),
                ),
                SizedBox(width: 10.w),
                GestureDetector(
                  onTap: () => context.router.maybePop(),
                  child: Center(
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
        body: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            return GridView.builder(
              cacheExtent: state.searchedMovies.length * 10,
              itemCount: state.searchedMovies.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 0.7.r,
                crossAxisCount: 2,
              ),
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: CachedNetworkImage(
                    placeholder: (context, url) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade600,
                        highlightColor: Colors.grey.shade500,
                        child: Container(
                          width: 300.w,
                          height: 300.h,
                          decoration: BoxDecoration(color: Colors.amber),
                        ),
                      );
                    },
                    imageUrl: state.searchedMovies[index].posterPath!.coverImage,
                    memCacheHeight: 1000,
                    fit: BoxFit.cover,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class RecommendedContainer extends StatelessWidget {
  final void Function()? onTap;
  final String imageUrl;
  final String tag;
  final bool isLoading;

  const RecommendedContainer({super.key, this.onTap, required this.imageUrl, required this.tag, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 40.h),
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
      height: 350.h,
      width: double.infinity,
      child: Column(
        spacing: 25.h,
        children: [
          !isLoading
              ? GestureDetector(
                  onTap: () => onTap,
                  child: Hero(
                    tag: tag,
                    child: CachedNetworkImage(
                      height: 250.h,
                      imageUrl: imageUrl,
                      memCacheHeight: 300,
                    ),
                  ),
                )
              : Shimmer.fromColors(
                  baseColor: Colors.grey.shade400,
                  highlightColor: Colors.grey.shade300,
                  child: Container(
                    height: 250.h,
                    width: 187.w,
                    color: Colors.black,
                  ),
                ),
          Text(
            "Recommended for you",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecommendedContainer extends StatelessWidget {
  final void Function()? onTap;
  final String imageUrl;
  final String tag;

  const RecommendedContainer({super.key, this.onTap, required this.imageUrl, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xff101010),
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
          GestureDetector(
            onTap: onTap,
            child: Hero(
              createRectTween: (begin, end) => RectTween(begin: begin, end: end),
              flightShuttleBuilder: (flightContext, animation, direction, fromHeroContext, toHeroContext) {
                if (direction == HeroFlightDirection.push) {
                  return Material(color: Colors.transparent, child: fromHeroContext.widget);
                } else {
                  return Material(color: Colors.transparent, child: toHeroContext.widget);
                }
              },
              tag: tag,
              child: ClipRRect(
                clipBehavior: Clip.hardEdge,
                borderRadius: BorderRadius.circular(15.r),
                child: CachedNetworkImage(
                  height: 250.h,
                  imageUrl: imageUrl,
                  memCacheHeight: 1000,
                ),
              ),
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

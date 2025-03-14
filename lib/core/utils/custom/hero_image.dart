import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HeroImage extends StatelessWidget {
  final String tag;
  final String imageUrl;

  const HeroImage({
    super.key,
    required this.tag,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
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
          placeholder: (context, url) => SizedBox(
            height: 250.h,
            width: 143.w,
          ),
          height: 250.h,
          imageUrl: imageUrl,
          memCacheHeight: 500,
        ),
      ),
    );
  }
}

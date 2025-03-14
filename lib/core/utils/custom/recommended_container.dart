import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'hero_image.dart';

class RecommendedContainer extends StatelessWidget {
  final void Function()? onTap;
  final String imageUrl;
  final String tag;

  const RecommendedContainer({
    super.key,
    this.onTap,
    required this.imageUrl,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20.h),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Color(0xff3a3a3a),
            Color(0xff101010),
          ],
          stops: [
            0.6.r,
            1.5.r,
          ],
          center: Alignment.bottomCenter,
          radius: 0.8.r,
        ),
      ),
      height: 350.h,
      width: double.infinity,
      child: Column(
        spacing: 20.h,
        children: [
          GestureDetector(
            onTap: onTap,
            child: HeroImage(
              tag: tag,
              imageUrl: imageUrl,
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

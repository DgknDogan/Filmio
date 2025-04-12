import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/routes/app_router.gr.dart';
import '../../../../core/extensions/brightness_extension.dart';
import '../../../../core/extensions/firebase_auth_extension.dart';

@RoutePage()
class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 20.w),
                  child: GestureDetector(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          context.router.push(SettingsRoute());
                        },
                        child: Icon(
                          Icons.settings,
                          size: 40.r,
                          color: Theme.of(context).isLight ? Color(0xff353839) : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: CircleAvatar(
                    maxRadius: 45.r,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).isLight ? Color(0xff353839) : Colors.white,
                        ),
                        borderRadius: BorderRadius.circular(45.r),
                      ),
                      child: Image.asset(FirebaseAuth.instance.userPhoto),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Divider(indent: 5.w, endIndent: 5.w),
            SizedBox(height: 10.h),
            GestureDetector(
              onTap: () => context.router.push(LikedMoviesRoute()),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10.w),
                height: 150.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.all(
                    Radius.circular(20.r),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.w),
                      height: 100.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.all(
                          Radius.circular(20.r),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: Icon(
                        Icons.movie_filter_rounded,
                        size: 40.r,
                        color: Colors.grey.shade300,
                      ),
                    ),
                    Text(
                      "Liked Movies",
                      style: Theme.of(context).textTheme.titleMedium,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

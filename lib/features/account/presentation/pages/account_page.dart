import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/routes/app_router.gr.dart';
import '../../../../injection_container.dart';

final _auth = FirebaseAuth.instance;

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
                    onTap: () async {
                      await getIt<SharedPreferences>().clear();
                      if (context.mounted) {
                        context.router.replace(LoginRoute());
                      }
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.exit_to_app,
                        size: 40.r,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: CircleAvatar(
                    maxRadius: 45.r,
                    child: Image.asset(_auth.currentUser!.photoURL!),
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

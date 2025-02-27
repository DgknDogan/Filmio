import 'package:filmio/injection_container.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/routes/app_router.dart';
import 'config/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initDependencies();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

final _appRouter = AppRouter();

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690),
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          routerConfig: _appRouter.config(),
          title: 'Filmio',
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}

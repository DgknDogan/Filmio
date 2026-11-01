import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/firebase/firebase_setup.dart';
import 'config/l10n/app_localizations.dart';
import 'config/routes/app_router.dart';
import 'config/theme/cubit/theme_cubit.dart';
import 'config/theme/theme.dart';
import 'core/cubit/session_cubit.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Which project this opens — and whether it opens the emulators instead —
  // is decided in `config/firebase/firebase_setup.dart`, not here.
  await initializeFirebase();
  await ScreenUtil.ensureScreenSize();
  await initDependencies();
  runApp(const MyApp());
}

final _appRouter = AppRouter();

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => getIt<ThemeCubit>()),
            BlocProvider(create: (context) => getIt<SessionCubit>()),
          ],
          child: BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: state.mode,
                // The observer is what makes `AutoRouteAwareStateMixin`
                // work: without one in this list, a page asking to be told
                // when its tab comes back to the front is simply never told.
                routerConfig: _appRouter.config(
                  navigatorObservers: () => [AutoRouteObserver()],
                ),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                title: 'Filmio',
                builder: (context, child) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      final currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                        currentFocus.focusedChild!.unfocus();
                      }
                    },
                    child: child,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

import 'package:filmio/config/l10n/app_localizations.dart';
import 'package:filmio/config/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

extension PumpApp on WidgetTester {
  /// Wraps a widget in everything it needs to build: the app theme, the
  /// localization delegates, ScreenUtil, and any blocs it reads.
  ///
  /// Anything a widget test renders goes through here, so a screen never has to
  /// be told about `MaterialApp` twice.
  Future<void> pumpApp(Widget widget, {List<BlocProvider> providers = const [], Brightness? brightness}) {
    // The default 800x600 test surface is not a phone, and these screens size
    // themselves with screenutil against a 360x690 design. Pin a phone-shaped
    // surface so a test failure means a real layout problem.
    view.physicalSize = const Size(1179, 2556);
    view.devicePixelRatio = 3;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);

    return pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        builder: (context, child) => MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: providers.isEmpty ? widget : MultiBlocProvider(providers: providers, child: widget),
        ),
      ),
    );
  }
}
